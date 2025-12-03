import Vapor
import Fluent

struct AttendanceController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let attendance = routes.grouped("api", "attendance")
        attendance.get("sessions", use: sessions)
        attendance.get("sessions", ":sessionID", use: sessionDetail)
        attendance.get("records", use: records)
        attendance.get("settings", use: getSettings)
        attendance.put("settings", use: updateSettings)
    }
    
    func sessions(req: Request) async throws -> [AttendanceSession.Public] {
        let query = AttendanceSession.query(on: req.db)
        
        if let dateStr = req.query[String.self, at: "date"] {
            let formatter = ISO8601DateFormatter()
            formatter.formatOptions = [.withFullDate]
            if let date = formatter.date(from: dateStr) {
                query.filter(\.$date == date.stripTime())
            }
        }
        
        if let kindStr = req.query[String.self, at: "kind"],
           let kind = SessionKind(rawValue: kindStr) {
            query.filter(\.$kind == kind)
        }
        
        let sessions = try await query
            .sort(\.$date, .descending)
            .all()
        
        return sessions.map { session in
            var publicSession = session.toPublic()
            // Contar records (pode ser otimizado com aggregate)
            Task {
                try? await session.$records.load(on: req.db)
            }
            return publicSession
        }
    }
    
    func sessionDetail(req: Request) async throws -> SessionDetailResponse {
        guard let session = try await AttendanceSession.find(req.parameters.get("sessionID"), on: req.db) else {
            throw Abort(.notFound)
        }
        
        try await session.$records.load(on: req.db)
        let records = try await session.records.asyncMap { try await $0.toPublic(on: req.db) }
        
        return SessionDetailResponse(
            session: session.toPublic(),
            records: records
        )
    }
    
    func records(req: Request) async throws -> [AttendanceRecord.Public] {
        let query = AttendanceRecord.query(on: req.db)
            .with(\.$beacon)
            .with(\.$session)
        
        if let sessionID = req.query[UUID.self, at: "sessionID"] {
            query.filter(\.$session.$id == sessionID)
        }
        
        if let beaconID = req.query[UUID.self, at: "beaconID"] {
            query.filter(\.$beacon.$id == beaconID)
        }
        
        let records = try await query
            .sort(\.$createdAt, .descending)
            .all()
        
        return try await records.asyncMap { try await $0.toPublic(on: req.db) }
    }
    
    func getSettings(req: Request) async throws -> AppSettings.Public {
        guard let settings = try await AppSettings.query(on: req.db).first() else {
            // Criar padrão se não existir
            let defaultSettings = AppSettings.makeDefault()
            try await defaultSettings.save(on: req.db)
            return defaultSettings.toPublic()
        }
        return settings.toPublic()
    }
    
    func updateSettings(req: Request) async throws -> AppSettings.Public {
        let update = try req.content.decode(AppSettings.Update.self)
        
        let settings: AppSettings
        if let existing = try await AppSettings.query(on: req.db).first() {
            settings = existing
        } else {
            settings = AppSettings.makeDefault()
            try await settings.save(on: req.db)
        }
        
        if let presenceStart = update.presenceStart {
            settings.presenceStart = presenceStart
        }
        if let presenceCutoff = update.presenceCutoff {
            settings.presenceCutoff = presenceCutoff
        }
        if let exitStart = update.exitStart {
            settings.exitStart = exitStart
        }
        if let exitCutoff = update.exitCutoff {
            settings.exitCutoff = exitCutoff
        }
        
        // Mensagens são sempre fixas - não podem ser alteradas
        // Garantir que sempre tenham os valores fixos
        settings.presenceMessage = AppSettings.fixedPresenceMessage()
        settings.absenceMessage = AppSettings.fixedAbsenceMessage()
        settings.leftMessage = AppSettings.fixedLeftMessage()
        settings.notLeftMessage = AppSettings.fixedNotLeftMessage()
        
        try await settings.save(on: req.db)
        return settings.toPublic()
    }
}

struct SessionDetailResponse: Content {
    var session: AttendanceSession.Public
    var records: [AttendanceRecord.Public]
}

