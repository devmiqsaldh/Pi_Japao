import Foundation
import SwiftData

@Model
final class Beacon {
    @Attribute(.unique) var id: String
    var name: String
    var email: String?
    var phone: String?
    var isActive: Bool

    init(id: String, name: String, email: String? = nil, phone: String? = nil, isActive: Bool = true) {
        self.id = id
        self.name = name
        self.email = email
        self.phone = phone
        self.isActive = isActive
    }
}

enum SessionKind: String, Codable, CaseIterable {
    case presence
    case exit
}

enum AttendanceStatus: String, Codable, CaseIterable {
    case present
    case absent
    case left
    case notLeft
}

@Model
final class AttendanceSession {
    var date: Date // normalized to day (00:00)
    var kindRaw: String
    var startTime: Date
    var cutoffTime: Date
    var closedAt: Date?
    var records: [AttendanceRecord] = []

    var kind: SessionKind {
        get { SessionKind(rawValue: kindRaw) ?? .presence }
        set { kindRaw = newValue.rawValue }
    }

    init(date: Date, kind: SessionKind, startTime: Date, cutoffTime: Date, closedAt: Date? = nil) {
        self.date = date.stripTime()
        self.kindRaw = kind.rawValue
        self.startTime = startTime
        self.cutoffTime = cutoffTime
        self.closedAt = closedAt
    }
}

@Model
final class AttendanceRecord {
    var beacon: Beacon?
    var session: AttendanceSession?
    var statusRaw: String
    var createdAt: Date
    var updatedAt: Date
    var messageLog: [String]

    var status: AttendanceStatus {
        get { AttendanceStatus(rawValue: statusRaw) ?? .present }
        set { statusRaw = newValue.rawValue }
    }

    init(beacon: Beacon, session: AttendanceSession, status: AttendanceStatus, createdAt: Date = .now, updatedAt: Date = .now, messageLog: [String] = []) {
        self.beacon = beacon
        self.session = session
        self.statusRaw = status.rawValue
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.messageLog = messageLog
    }
}

@Model
final class AppSettings {
    var presenceStart: Date
    var presenceCutoff: Date
    var exitStart: Date
    var exitCutoff: Date

    var presenceMessage: String
    var absenceMessage: String
    var leftMessage: String
    var notLeftMessage: String

    init(
        presenceStart: Date,
        presenceCutoff: Date,
        exitStart: Date,
        exitCutoff: Date,
        presenceMessage: String,
        absenceMessage: String,
        leftMessage: String,
        notLeftMessage: String
    ) {
        self.presenceStart = presenceStart
        self.presenceCutoff = presenceCutoff
        self.exitStart = exitStart
        self.exitCutoff = exitCutoff
        self.presenceMessage = presenceMessage
        self.absenceMessage = absenceMessage
        self.leftMessage = leftMessage
        self.notLeftMessage = notLeftMessage
    }

    static func makeDefault(for day: Date = .now) -> AppSettings {
        let cal = Calendar.current
        let date = day.stripTime()
        let presenceStart = cal.date(bySettingHour: 8, minute: 0, second: 0, of: date)!
        let presenceCutoff = cal.date(bySettingHour: 8, minute: 30, second: 0, of: date)!
        let exitStart = cal.date(bySettingHour: 17, minute: 0, second: 0, of: date)!
        let exitCutoff = cal.date(bySettingHour: 17, minute: 30, second: 0, of: date)!

        return AppSettings(
            presenceStart: presenceStart,
            presenceCutoff: presenceCutoff,
            exitStart: exitStart,
            exitCutoff: exitCutoff,
            presenceMessage: "Presença registrada para {name} às {time}.",
            absenceMessage: "Falta registrada para {name}.",
            leftMessage: "Saída registrada para {name} às {time}.",
            notLeftMessage: "Não saiu registrado para {name}."
        )
    }
}

extension Date {
    func stripTime() -> Date {
        let cal = Calendar.current
        return cal.startOfDay(for: self)
    }
}
