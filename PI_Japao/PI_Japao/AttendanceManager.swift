import Foundation
import SwiftData
import Observation

@Observable
final class AttendanceManager {
    private(set) var currentPresenceSession: AttendanceSession?
    private(set) var currentExitSession: AttendanceSession?

    private var scanner: BeaconScanner = BeaconScannerMock()
    private var sender: MessageSender = MessageSenderMock()

    private var presenceTimerTask: Task<Void, Never>?
    private var exitTimerTask: Task<Void, Never>?

    private var context: ModelContext?

    func bootstrapIfNeeded(context: ModelContext) async {
        self.context = context

        if (try? context.fetch(FetchDescriptor<AppSettings>()))?.isEmpty ?? true {
            let settings = AppSettings.makeDefault()
            context.insert(settings)
            try? context.save()
        }

        scanner.onDetect = { [weak self] id in
            Task { await self?.handleDetection(beaconID: id) }
        }
        scanner.start()

        await scheduleDailySessions()
    }

    private func loadSettings() -> AppSettings? {
        guard let context else { return nil }
        return try? context.fetch(FetchDescriptor<AppSettings>()).first
    }

    private func fetchAllBeacons() -> [Beacon] {
        guard let context else { return [] }
        return (try? context.fetch(FetchDescriptor<Beacon>())) ?? []
    }

    private func ensureSession(kind: SessionKind, for day: Date) -> AttendanceSession? {
        guard let context, let settings = loadSettings() else { return nil }
        let date = day.stripTime()

        let start: Date
        let cutoff: Date
        switch kind {
        case .presence:
            start = settings.presenceStart.aligned(to: date)
            cutoff = settings.presenceCutoff.aligned(to: date)
        case .exit:
            start = settings.exitStart.aligned(to: date)
            cutoff = settings.exitCutoff.aligned(to: date)
        }

        let predicate = #Predicate<AttendanceSession> { s in
            s.date == date && s.kindRaw == kind.rawValue
        }
        let fetch = FetchDescriptor<AttendanceSession>(predicate: predicate)
        if let existing = try? context.fetch(fetch).first {
            return existing
        } else {
            let session = AttendanceSession(date: date, kind: kind, startTime: start, cutoffTime: cutoff)
            context.insert(session)
            try? context.save()
            return session
        }
    }

    // Busca sem usar #Predicate com relacionamentos: tudo em memória
    private func allRecords() -> [AttendanceRecord] {
        guard let context else { return [] }
        return (try? context.fetch(FetchDescriptor<AttendanceRecord>())) ?? []
    }

    private func records(of session: AttendanceSession) -> [AttendanceRecord] {
        // Filtra por identidade de sessão em memória
        return allRecords().filter { $0.session === session }
    }

    private func record(for beacon: Beacon, in session: AttendanceSession) -> AttendanceRecord? {
        return records(of: session).first { $0.beacon?.id == beacon.id }
    }

    private func createOrFetchRecord(for beacon: Beacon, in session: AttendanceSession, defaultStatus: AttendanceStatus) -> AttendanceRecord {
        guard let context else { fatalError("No context") }
        if let existing = record(for: beacon, in: session) {
            return existing
        } else {
            let record = AttendanceRecord(beacon: beacon, session: session, status: defaultStatus)
            context.insert(record)
            session.records.append(record)
            return record
        }
    }

    private func updateRecord(_ record: AttendanceRecord, status: AttendanceStatus, appendLog: String?) {
        record.status = status
        record.updatedAt = .now
        if let appendLog {
            record.messageLog.append(appendLog)
        }
    }

    private func formatMessage(template: String, beacon: Beacon) -> String {
        let time = Date.now.formatted(date: .omitted, time: .shortened)
        return template
            .replacingOccurrences(of: "{name}", with: beacon.name)
            .replacingOccurrences(of: "{time}", with: time)
    }

    private func handleDetection(beaconID: String) async {
        guard let context else { return }
        let predicate = #Predicate<Beacon> { $0.id == beaconID }
        guard let beacon = try? context.fetch(FetchDescriptor<Beacon>(predicate: predicate)).first else { return }
        guard beacon.isActive == true else { return }

        guard let settings = loadSettings() else { return }
        let now = Date()

        if let session = currentPresenceSession, now >= session.startTime && now <= session.cutoffTime {
            let record = createOrFetchRecord(for: beacon, in: session, defaultStatus: .present)
            let msg = formatMessage(template: settings.presenceMessage, beacon: beacon)
            await sender.send(toEmail: beacon.email, phone: beacon.phone, message: msg)
            updateRecord(record, status: .present, appendLog: "Sent presence: \(msg)")
            try? context.save()
            return
        }

        if let session = currentExitSession, now >= session.startTime && now <= session.cutoffTime {
            let record = createOrFetchRecord(for: beacon, in: session, defaultStatus: .left)
            let msg = formatMessage(template: settings.leftMessage, beacon: beacon)
            await sender.send(toEmail: beacon.email, phone: beacon.phone, message: msg)
            updateRecord(record, status: .left, appendLog: "Sent left: \(msg)")
            try? context.save()
            return
        }
    }

    private func scheduleDailySessions() async {
        presenceTimerTask?.cancel()
        exitTimerTask?.cancel()

        _ = loadSettings() // garante existência

        let today = Date().stripTime()
        let presence = ensureSession(kind: .presence, for: today)
        let exit = ensureSession(kind: .exit, for: today)
        self.currentPresenceSession = presence
        self.currentExitSession = exit

        presenceTimerTask = Task { [weak self] in
            await self?.runSessionLoop(kind: .presence)
        }
        exitTimerTask = Task { [weak self] in
            await self?.runSessionLoop(kind: .exit)
        }
    }

    private func runSessionLoop(kind: SessionKind) async {
        while !Task.isCancelled {
            guard let session = (kind == .presence ? currentPresenceSession : currentExitSession) else { break }
            let now = Date()

            if now < session.cutoffTime {
                let interval = session.cutoffTime.timeIntervalSince(now)
                if interval > 0 {
                    let ns = UInt64(interval * 1_000_000_000)
                    try? await Task.sleep(nanoseconds: ns)
                }
            }

            await closeSession(session, kind: kind)
            await prepareNextDay(kind: kind)
        }
    }

    private func closeSession(_ session: AttendanceSession, kind: SessionKind) async {
        guard let context, let settings = loadSettings() else { return }
        session.closedAt = .now

        let beacons = fetchAllBeacons().filter { $0.isActive == true }
        let setDetectedIDs: Set<String> = Set(records(of: session).compactMap { $0.beacon?.id })

        for beacon in beacons {
            if !setDetectedIDs.contains(beacon.id) {
                switch kind {
                case .presence:
                    let record = createOrFetchRecord(for: beacon, in: session, defaultStatus: .absent)
                    let msg = formatMessage(template: settings.absenceMessage, beacon: beacon)
                    await sender.send(toEmail: beacon.email, phone: beacon.phone, message: msg)
                    updateRecord(record, status: .absent, appendLog: "Sent absence: \(msg)")
                case .exit:
                    let record = createOrFetchRecord(for: beacon, in: session, defaultStatus: .notLeft)
                    let msg = formatMessage(template: settings.notLeftMessage, beacon: beacon)
                    await sender.send(toEmail: beacon.email, phone: beacon.phone, message: msg)
                    updateRecord(record, status: .notLeft, appendLog: "Sent not-left: \(msg)")
                }
            }
        }

        try? context.save()
    }

    private func prepareNextDay(kind: SessionKind) async {
        let nextDay = Calendar.current.date(byAdding: .day, value: 1, to: Date().stripTime())!
        let session = ensureSession(kind: kind, for: nextDay)
        if kind == .presence {
            currentPresenceSession = session
        } else {
            currentExitSession = session
        }
    }

    // Público para simulações via UI
    func simulateDetect(id: String) {
        (scanner as? BeaconScannerMock)?.simulateDetect(id: id)
    }
}

private extension Date {
    func aligned(to day: Date) -> Date {
        let cal = Calendar.current
        let comps = cal.dateComponents([.hour, .minute, .second], from: self)
        return cal.date(bySettingHour: comps.hour ?? 0, minute: comps.minute ?? 0, second: comps.second ?? 0, of: day) ?? day
    }
}
