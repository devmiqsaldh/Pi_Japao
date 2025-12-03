import Vapor
import Fluent
import FluentSQLiteDriver

public func configure(_ app: Application) async throws {
    // Configuração de CORS para permitir requisições do app iOS
    let corsConfiguration = CORSMiddleware.Configuration(
        allowedOrigin: .all,
        allowedMethods: [.GET, .POST, .PUT, .OPTIONS, .DELETE, .PATCH],
        allowedHeaders: [.accept, .authorization, .contentType, .origin, .xRequestedWith, .userAgent, .accessControlAllowOrigin]
    )
    let cors = CORSMiddleware(configuration: corsConfiguration)
    app.middleware.use(cors, at: .beginning)
    
    // Configuração do banco de dados
    app.databases.use(.sqlite(.file("attendance.db")), as: .sqlite)
    
    // Migrações
    app.migrations.add(CreateBeaconMigration())
    app.migrations.add(CreateStudentMigration())
    app.migrations.add(CreateAttendanceSessionMigration())
    app.migrations.add(CreateAttendanceRecordMigration())
    app.migrations.add(CreateAppSettingsMigration())
    
    // Registrar rotas
    try routes(app)
    
    // Executar migrações
    try await app.autoMigrate()
}

