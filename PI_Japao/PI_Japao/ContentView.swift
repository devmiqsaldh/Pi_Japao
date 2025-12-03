//
//  ContentView.swift
//  PI_Japao
//
//  Created by Miqueias Saldanha on 28/10/25.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(AttendanceManager.self) private var attendanceManager
    @Environment(\.modelContext) private var context

    var body: some View {
        TabView {
            DashboardView()
                .tabItem {
                    Label("Dashboard", systemImage: "dot.radiowaves.left.and.right")
                }

            BeaconsListView()
                .tabItem {
                    Label("Beacons", systemImage: "antenna.radiowaves.left.and.right")
                }

            HistoryView()
                .tabItem {
                    Label("Histórico", systemImage: "clock.arrow.circlepath")
                }

            SettingsView()
                .tabItem {
                    Label("Configurações", systemImage: "gearshape")
                }
        }
        .task {
            await attendanceManager.bootstrapIfNeeded(context: context)
        }
    }
}

#Preview("ContentView Preview") {
    ContentView()
        .modelContainer(for: [
            Beacon.self, AttendanceSession.self, AttendanceRecord.self, AppSettings.self
        ], inMemory: true)
        .environment(AttendanceManager())
}
