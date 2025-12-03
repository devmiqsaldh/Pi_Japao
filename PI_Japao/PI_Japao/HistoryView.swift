import SwiftUI
import SwiftData

struct HistoryView: View {
    @Query(sort: \AttendanceSession.date, order: .reverse, animation: .default)
    private var sessions: [AttendanceSession]

    var body: some View {
        NavigationStack {
            List {
                ForEach(sessions) { session in
                    NavigationLink {
                        SessionDetailView(session: session)
                    } label: {
                        VStack(alignment: .leading) {
                            Text(session.kind == .presence ? "Presença" : "Saída")
                                .font(.headline)
                            HStack {
                                Text(session.date, style: .date)
                                Spacer()
                                Text("Registros: \(session.records.count)")
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Histórico")
        }
    }
}

struct SessionDetailView: View {
    var session: AttendanceSession

    var body: some View {
        List {
            ForEach(session.records) { record in
                VStack(alignment: .leading, spacing: 6) {
                    Text(record.beacon?.name ?? "(Removido)")
                        .font(.headline)
                    Text("Status: \(record.status.rawValue)")
                    if !record.messageLog.isEmpty {
                        ForEach(Array(record.messageLog.enumerated()), id: \.offset) { _, line in
                            Text("• \(line)").font(.caption)
                        }
                    }
                    Text("Atualizado: \(record.updatedAt.formatted(date: .omitted, time: .shortened))")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .navigationTitle(session.kind == .presence ? "Detalhe Presença" : "Detalhe Saída")
    }
}

#Preview("HistoryView Preview - Empty") {
    HistoryView()
        .modelContainer(for: [
            Beacon.self, AttendanceSession.self, AttendanceRecord.self, AppSettings.self
        ], inMemory: true)
}

#Preview("HistoryView Preview - With Data") {
    let container = try! ModelContainer(for: Beacon.self, AttendanceSession.self, AttendanceRecord.self, AppSettings.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
    let context = ModelContext(container)

    let settings = AppSettings.makeDefault()
    context.insert(settings)

    let today = Date().stripTime()
    let presence = AttendanceSession(date: today, kind: .presence, startTime: settings.presenceStart, cutoffTime: settings.presenceCutoff)
    context.insert(presence)
    let b1 = Beacon(id: "A001", name: "Aluno 1")
    let b2 = Beacon(id: "A002", name: "Aluno 2")
    context.insert(b1); context.insert(b2)
    let r1 = AttendanceRecord(beacon: b1, session: presence, status: .present)
    let r2 = AttendanceRecord(beacon: b2, session: presence, status: .absent)
    context.insert(r1); context.insert(r2)
    presence.records.append(contentsOf: [r1, r2])

    return HistoryView()
        .modelContainer(container)
}

#Preview("SessionDetailView Preview") {
    let container = try! ModelContainer(for: Beacon.self, AttendanceSession.self, AttendanceRecord.self, AppSettings.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
    let context = ModelContext(container)

    let settings = AppSettings.makeDefault()
    context.insert(settings)

    let today = Date().stripTime()
    let presence = AttendanceSession(date: today, kind: .presence, startTime: settings.presenceStart, cutoffTime: settings.presenceCutoff)
    context.insert(presence)
    let b = Beacon(id: "A001", name: "Aluno 1")
    context.insert(b)
    let r = AttendanceRecord(beacon: b, session: presence, status: .present, messageLog: ["Sent presence: ok"])
    context.insert(r)
    presence.records.append(r)

    return NavigationStack {
        SessionDetailView(session: presence)
    }
    .modelContainer(container)
}
