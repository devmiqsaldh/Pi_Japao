import Fluent

struct CreateBeaconMigration: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema("beacons")
            .id()
            .field("beacon_id", .string, .required)
            .unique(on: "beacon_id")
            .field("name", .string, .required)
            .field("is_active", .bool, .required)
            .field("created_at", .datetime)
            .field("updated_at", .datetime)
            .create()
    }
    
    func revert(on database: Database) async throws {
        try await database.schema("beacons").delete()
    }
}

