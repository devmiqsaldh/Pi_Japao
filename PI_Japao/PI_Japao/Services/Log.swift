import os

/// Loggers da app, separados por área. Aparecem no Console do macOS
/// filtrando pelo subsystem "PI_Japao".
nonisolated enum Log {
    static let beacons = Logger(subsystem: "PI_Japao", category: "beacons")
    static let attendance = Logger(subsystem: "PI_Japao", category: "attendance")
    static let students = Logger(subsystem: "PI_Japao", category: "students")
}
