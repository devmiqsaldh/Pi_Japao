//
//  PI_JapaoApp.swift
//  PI_Japao
//
//  Created by Miqueias Saldanha on 28/10/25.
//

import SwiftUI

@main
struct PI_JapaoApp: App {
    @State private var attendanceManager = AttendanceManager()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(attendanceManager)
                .task {
                    await attendanceManager.initialize()
                }
        }
    }
}
