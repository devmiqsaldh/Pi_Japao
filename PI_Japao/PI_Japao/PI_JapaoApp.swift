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
    @State private var errorHandler = ErrorHandler()

    var body: some Scene {
        WindowGroup {
            SplashView()
                .environment(attendanceManager)
                .environment(errorHandler)
                .task {
                    await attendanceManager.initialize()
                }
        }
    }
}
