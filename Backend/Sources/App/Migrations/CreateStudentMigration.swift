import Fluent

struct CreateStudentMigration: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema("students")
            .id()
            .field("name", .string, .required)
            .field("email", .string)
            .field("phone", .string)
            .field("beacon_id", .uuid, .required, .references("beacons", "id", onDelete: .cascade))
            .field("created_at", .datetime)
            .field("updated_at", .datetime)
            .create()
    }
    
    func revert(on database: Database) async throws {
        try await database.schema("students").delete()
    }
}

