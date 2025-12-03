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
    @State private var errorHandler = ErrorHandler()

    var body: some View {
        TabView {
            DashboardView()
                .tabItem {
                    Label("Dashboard", systemImage: "chart.bar.fill")
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
        .toast(
            message: errorHandler.currentError ?? "",
            type: errorHandler.errorType,
            isPresented: $errorHandler.showError
        )
        .task {
            await checkConnection()
        }
    }
    
    private func checkConnection() async {
        await connectionStatus.checkConnection()
        if !connectionStatus.isConnected, let error = connectionStatus.errorMessage {
            errorHandler.show(error, type: .warning)
        }
    }
}

#Preview("ContentView Preview") {
    ContentView()
        .environment(AttendanceManager())
}
