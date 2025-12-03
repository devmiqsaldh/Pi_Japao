import SwiftUI

struct DashboardView: View {
    @State private var viewModel = DashboardViewModel()
    @Environment(AttendanceManager.self) private var attendanceManager

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Status Card
                    if let error = viewModel.errorMessage {
                        ErrorCard(message: error)
                    }
                    
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
                                Text("Nenhuma sessão ativa")
                                    .foregroundStyle(.secondary)
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
                            Text("Nenhum beacon cadastrado")
                                .foregroundStyle(.secondary)
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
                .padding()
            }
            .background(AppTheme.backgroundColor)
            .navigationTitle("Dashboard")
            .navigationBarTitleDisplayMode(.large)
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

#Preview("DashboardView") {
    DashboardView()
        .environment(AttendanceManager())
}
