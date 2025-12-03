import Fluent

struct CreateAttendanceSessionMigration: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema("attendance_sessions")
            .id()
            .field("date", .datetime, .required)
            .field("kind", .string, .required)
            .field("start_time", .datetime, .required)
            .field("cutoff_time", .datetime, .required)
            .field("closed_at", .datetime)
            .field("created_at", .datetime)
            .field("updated_at", .datetime)
            .unique(on: "date", "kind")
            .create()
    }
    
    func revert(on database: Database) async throws {
        try await database.schema("attendance_sessions").delete()
    }
}

