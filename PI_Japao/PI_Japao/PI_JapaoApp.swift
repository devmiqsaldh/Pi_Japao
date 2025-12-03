//
//  PI_JapaoApp.swift
//  PI_Japao
//
//  Created by Miqueias Saldanha on 28/10/25.
//

import SwiftUI
import SwiftData

@main
struct PI_JapaoApp: App {

    @State private var attendanceManager = AttendanceManager()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .modelContainer(Self.makeModelContainer())
                .environment(attendanceManager)
        }
    }

    static func makeModelContainer() -> ModelContainer {
        let schema = Schema([
            Beacon.self,
            AttendanceSession.self,
            AttendanceRecord.self,
            AppSettings.self
        ])
        let config = ModelConfiguration(isStoredInMemoryOnly: false)
        do {
            let container = try ModelContainer(for: schema, configurations: [config])
            return container
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }
    }
}
