import SwiftUI
import SwiftData

struct DashboardView: View {
    @Environment(AttendanceManager.self) private var manager
    @Environment(\.modelContext) private var context

    @Query(sort: \AttendanceSession.startTime, order: .forward, animation: .default)
    private var sessions: [AttendanceSession]

    @Query(sort: \Beacon.name, order: .forward, animation: .default)
    private var beacons: [Beacon]

    var body: some View {
        NavigationStack {
            List {
                Section("Sessões de hoje") {
                    if let p = manager.currentPresenceSession {
                        SessionRow(session: p)
                    }
                    if let e = manager.currentExitSession {
                        SessionRow(session: e)
                    }
                }

                Section("Ações") {
                    if !beacons.isEmpty {
                        ForEach(beacons) { beacon in
                            Button {
                                manager.simulateDetect(id: beacon.id)
                            } label: {
                                Label("Simular detecção: \(beacon.name)", systemImage: "wave.3.right")
                            }
                        }
                    } else {
                        Text("Cadastre beacons na aba Beacons.")
                    }
                }
            }
            .navigationTitle("Dashboard")
        }
    }
}

private struct SessionRow: View {
    var session: AttendanceSession

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(session.kind == .presence ? "Presença" : "Saída")
                    .font(.headline)
                Spacer()
                Text(session.date, style: .date)
                    .foregroundStyle(.secondary)
            }
            HStack {
                Image(systemName: "clock")
                Text(session.startTime, style: .time)
                Spacer()
                Text("Limite: \(session.cutoffTime.formatted(date: .omitted, time: .shortened))")
                    .foregroundStyle(.secondary)
            }
            if !session.records.isEmpty {
                Text("Registros: \(session.records.count)")
                    .font(.subheadline)
            }
        }
    }
}
