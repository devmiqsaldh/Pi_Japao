import Fluent

struct CreateAppSettingsMigration: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema("app_settings")
            .id()
            .field("presence_start", .datetime, .required)
            .field("presence_cutoff", .datetime, .required)
            .field("exit_start", .datetime, .required)
            .field("exit_cutoff", .datetime, .required)
            .field("presence_message", .string, .required)
            .field("absence_message", .string, .required)
            .field("left_message", .string, .required)
            .field("not_left_message", .string, .required)
            .field("created_at", .datetime)
            .field("updated_at", .datetime)
            .create()
        
        // Criar configuração padrão
        let defaultSettings = AppSettings.makeDefault()
        try await defaultSettings.save(on: database)
    }
    
    func revert(on database: Database) async throws {
        try await database.schema("app_settings").delete()
    }
}

