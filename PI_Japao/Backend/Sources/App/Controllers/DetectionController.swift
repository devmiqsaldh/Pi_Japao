import Vapor
import Fluent

struct DetectionController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let detections = routes.grouped("api", "detections")
        detections.post(use: detect)
    }
    
    func detect(req: Request) async throws -> DetectionResponse {
        let detection = try req.content.decode(DetectionRequest.self)
        
        // Buscar beacon pelo ID
        guard let beacon = try await Beacon.query(on: req.db)
            .filter(\.$beaconID == detection.beaconID)
            .first() else {
            throw Abort(.notFound, reason: "Beacon '\(detection.beaconID)' não encontrado")
        }
        
        guard beacon.isActive else {
            throw Abort(.badRequest, reason: "Beacon está inativo")
        }
        
        // Buscar alunos associados ao beacon
        let students = try await Student.query(on: req.db)
            .filter(\.$beacon.$id == beacon.id!)
            .all()
        
        guard !students.isEmpty else {
            throw Abort(.badRequest, reason: "Nenhum aluno associado a este beacon")
        }
        
        // Buscar configurações
        guard let settings = try await AppSettings.query(on: req.db).first() else {
            throw Abort(.internalServerError, reason: "Configurações não encontradas")
        }
        
        let now = Date()
        let today = now.stripTime()
        
        // Determinar tipo de sessão baseado no horário
        var sessionKind: SessionKind?
        if now >= settings.presenceStart.aligned(to: today) && now <= settings.presenceCutoff.aligned(to: today) {
            sessionKind = .presence
        } else if now >= settings.exitStart.aligned(to: today) && now <= settings.exitCutoff.aligned(to: today) {
            sessionKind = .exit
        }
        
        guard let kind = sessionKind else {
            return DetectionResponse(
                success: false,
                message: "Fora da janela de detecção",
                beaconID: detection.beaconID
            )
        }
        
        // Buscar ou criar sessão do dia
        let session = try await ensureSession(
            kind: kind,
            date: today,
            startTime: kind == .presence ? settings.presenceStart.aligned(to: today) : settings.exitStart.aligned(to: today),
            cutoffTime: kind == .presence ? settings.presenceCutoff.aligned(to: today) : settings.exitCutoff.aligned(to: today),
            on: req.db
        )
        
        // Processar cada aluno
        var processedStudents: [String] = []
        for student in students {
            // Buscar ou criar record
            let record = try await ensureRecord(
                beaconID: beacon.id!,
                sessionID: session.id!,
                defaultStatus: kind == .presence ? .present : .left,
                on: req.db
            )
            
            // Atualizar status se necessário
            let newStatus: AttendanceStatus = kind == .presence ? .present : .left
            if record.status != newStatus {
                record.status = newStatus
                record.updatedAt = Date()
            }
            
            // Formatar e enviar mensagem
            let message = formatMessage(
                template: kind == .presence ? settings.presenceMessage : settings.leftMessage,
                student: student,
                time: now
            )
            
            // Enviar mensagem apenas por Email (gratuito)
            // SMS desabilitado por enquanto (requer serviço pago)
            try await MessageService.shared.send(
                toEmail: student.email,
                phone: nil, // SMS desabilitado
                message: message,
                on: req.db
            )
            
            record.messageLog.append("Sent \(kind == .presence ? "presence" : "left"): \(message)")
            try await record.save(on: req.db)
            
            processedStudents.append(student.name)
        }
        
        return DetectionResponse(
            success: true,
            message: "Detecção processada para: \(processedStudents.joined(separator: ", "))",
            beaconID: detection.beaconID,
            students: processedStudents
        )
    }
    
    private func ensureSession(
        kind: SessionKind,
        date: Date,
        startTime: Date,
        cutoffTime: Date,
        on database: Database
    ) async throws -> AttendanceSession {
        if let existing = try await AttendanceSession.query(on: database)
            .filter(\.$date == date)
            .filter(\.$kind == kind)
            .first() {
            return existing
        }
        
        let session = AttendanceSession(
            date: date,
            kind: kind,
            startTime: startTime,
            cutoffTime: cutoffTime
        )
        try await session.save(on: database)
        return session
    }
    
    private func ensureRecord(
        beaconID: UUID,
        sessionID: UUID,
        defaultStatus: AttendanceStatus,
        on database: Database
    ) async throws -> AttendanceRecord {
        if let existing = try await AttendanceRecord.query(on: database)
            .filter(\.$beacon.$id == beaconID)
            .filter(\.$session.$id == sessionID)
            .first() {
            return existing
        }
        
        let record = AttendanceRecord(
            beaconID: beaconID,
            sessionID: sessionID,
            status: defaultStatus
        )
        try await record.save(on: database)
        return record
    }
    
    private func formatMessage(template: String, student: Student, time: Date) -> String {
        let timeStr = time.formatted(date: .omitted, time: .shortened)
        return template
            .replacingOccurrences(of: "{name}", with: student.name)
            .replacingOccurrences(of: "{time}", with: timeStr)
    }
}

struct DetectionRequest: Content {
    var beaconID: String
    var timestamp: Date?
}

struct DetectionResponse: Content {
    var success: Bool
    var message: String
    var beaconID: String
    var students: [String]?
}

