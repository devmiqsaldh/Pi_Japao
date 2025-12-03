//
//  ContentView.swift
//  PI_Japao
//
//  Created by Miqueias Saldanha on 28/10/25.
//

import SwiftUI

struct ContentView: View {
    @Environment(AttendanceManager.self) private var attendanceManager

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
            
            StudentsListView()
                .tabItem {
                    Label("Alunos", systemImage: "person.2")
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
    }
}

#Preview("ContentView Preview") {
    ContentView()
        .environment(AttendanceManager())
}
