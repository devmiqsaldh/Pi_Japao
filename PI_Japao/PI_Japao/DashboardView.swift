import SwiftUI

struct DashboardView: View {
    @State private var viewModel = DashboardViewModel()
    @Environment(AttendanceManager.self) private var attendanceManager

    var body: some View {
        NavigationStack {
            List {
                Section("Sessões de hoje") {
                    if let p = viewModel.currentPresenceSession {
                        SessionRow(session: p)
                    }
                    if let e = viewModel.currentExitSession {
                        SessionRow(session: e)
                    }
                    
                    if viewModel.isLoading {
                        ProgressView()
                    }
                }

                Section("Beacons Ativos") {
                    if viewModel.beacons.isEmpty {
                        Text("Nenhum beacon cadastrado")
                            .foregroundStyle(.secondary)
                    } else {
                        ForEach(viewModel.beacons.filter { $0.isActive }) { beacon in
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(beacon.name)
                                        .font(.headline)
                                    Text("ID: \(beacon.beaconID)")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                Spacer()
                                if viewModel.isLoading {
                                    ProgressView()
                                }
                            }
                        }
                    }
                }
                
                if let error = viewModel.errorMessage {
                    Section {
                        Text(error)
                            .foregroundStyle(.red)
                    }
                }
            }
            .navigationTitle("Dashboard")
            .task {
                await viewModel.start()
            }
            .onDisappear {
                viewModel.stop()
            }
            .refreshable {
                await viewModel.start()
            }
        }
    }
}

private struct SessionRow: View {
    var session: AttendanceSessionDTO

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
            if let count = session.recordsCount, count > 0 {
                Text("Registros: \(count)")
                    .font(.subheadline)
            }
        }
    }
}
