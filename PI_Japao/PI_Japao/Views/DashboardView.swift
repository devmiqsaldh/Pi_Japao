import SwiftUI

struct DashboardView: View {
    @State private var viewModel = DashboardViewModel()
    @Environment(AttendanceManager.self) private var attendanceManager
    @Environment(ErrorHandler.self) private var errorHandler

    var body: some View {
        NavigationStack {
            ScrollView {
                AdaptiveStack {
                    VStack(spacing: 20) {
                        // Sessões Card
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Image(systemName: "calendar.badge.clock")
                                    .font(.title2)
                                    .foregroundColor(AppTheme.primaryColor)
                                Text("Sessões de Hoje")
                                    .font(AppTheme.headlineFont)
                            }
                            
                            if viewModel.isLoading {
                                HStack {
                                    Spacer()
                                    ProgressView()
                                    Spacer()
                                }
                                .padding()
                            } else {
                                if let p = viewModel.currentPresenceSession {
                                    SessionCard(session: p)
                                }
                                if let e = viewModel.currentExitSession {
                                    SessionCard(session: e)
                                }
                                if viewModel.currentPresenceSession == nil && viewModel.currentExitSession == nil {
                                    VStack(spacing: 8) {
                                        Image(systemName: "calendar.badge.exclamationmark")
                                            .font(.title)
                                            .foregroundStyle(.secondary)
                                        Text("Nenhuma sessão ativa")
                                            .foregroundStyle(.secondary)
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                }
                            }
                        }
                        .padding()
                        .cardStyle()
                        
                        // Beacons Card
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Image(systemName: "antenna.radiowaves.left.and.right")
                                    .font(.title2)
                                    .foregroundColor(AppTheme.accentColor)
                                Text("Beacons Ativos")
                                    .font(AppTheme.headlineFont)
                                Spacer()
                                Text("\(viewModel.beacons.filter { $0.isActive }.count)")
                                    .font(.title3)
                                    .fontWeight(.bold)
                                    .foregroundColor(AppTheme.primaryColor)
                            }
                            
                            if viewModel.beacons.isEmpty {
                                VStack(spacing: 8) {
                                    Image(systemName: "antenna.radiowaves.left.and.right.slash")
                                        .font(.title)
                                        .foregroundStyle(.secondary)
                                    Text("Nenhum beacon cadastrado")
                                        .foregroundStyle(.secondary)
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                            } else {
                                ForEach(viewModel.beacons.filter { $0.isActive }) { beacon in
                                    BeaconCard(beacon: beacon)
                                }
                            }
                        }
                        .padding()
                        .cardStyle()
                    }
                    .adaptivePadding()
                }
            }
            .background(AppTheme.backgroundColor)
            .navigationTitle("Dashboard")
            .navigationBarTitleDisplayMode(.large)
            .task {
                await loadData()
            }
            .onDisappear {
                viewModel.stop()
            }
            .refreshable {
                await loadData()
            }
        }
    }
    
    private func loadData() async {
        do {
            try await viewModel.start()
        } catch {
            errorHandler.handleAPIError(error)
        }
    }
}

#Preview("DashboardView") {
    DashboardView()
        .environment(AttendanceManager())
}
