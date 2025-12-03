//
//  ContentView.swift
//  PI_Japao
//
//  Created by Miqueias Saldanha on 28/10/25.
//

import SwiftUI

struct ContentView: View {
    @Environment(AttendanceManager.self) private var attendanceManager
    @State private var connectionStatus = ConnectionStatusViewModel()

    var body: some View {
        TabView {
            DashboardView()
                .tabItem {
                    Label("Dashboard", systemImage: "chart.bar.fill")
                }

            BeaconsListView()
                .tabItem {
                    Label("Beacons", systemImage: "antenna.radiowaves.left.and.right")
                }
            
            StudentsListView()
                .tabItem {
                    Label("Alunos", systemImage: "person.2.fill")
                }

            HistoryView()
                .tabItem {
                    Label("Histórico", systemImage: "clock.fill")
                }

            SettingsView()
                .tabItem {
                    Label("Configurações", systemImage: "gearshape.fill")
                }
        }
        .tint(AppTheme.primaryColor)
        .overlay(alignment: .top) {
            if !connectionStatus.isConnected {
                ConnectionBanner(status: connectionStatus)
            }
        }
        .task {
            await connectionStatus.checkConnection()
        }
    }
}

struct ConnectionBanner: View {
    @State var status: ConnectionStatusViewModel
    
    var body: some View {
        VStack {
            HStack {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundColor(.white)
                Text(status.errorMessage ?? "Sem conexão com o backend")
                    .font(.subheadline)
                    .foregroundColor(.white)
                Spacer()
                Button {
                    Task {
                        await status.checkConnection()
                    }
                } label: {
                    Image(systemName: "arrow.clockwise")
                        .foregroundColor(.white)
                }
            }
            .padding()
            .background(AppTheme.errorColor)
        }
        .transition(.move(edge: .top))
    }
}

#Preview("ContentView Preview") {
    ContentView()
        .environment(AttendanceManager())
}
