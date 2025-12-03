import Fluent

struct CreateAttendanceRecordMigration: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema("attendance_records")
            .id()
            .field("beacon_id", .uuid, .required, .references("beacons", "id", onDelete: .cascade))
            .field("session_id", .uuid, .required, .references("attendance_sessions", "id", onDelete: .cascade))
            .field("status", .string, .required)
            .field("message_log", .array(of: .string))
            .field("created_at", .datetime)
            .field("updated_at", .datetime)
            .unique(on: "beacon_id", "session_id")
            .create()
    }
    
    func revert(on database: Database) async throws {
        try await database.schema("attendance_records").delete()
    }
}

