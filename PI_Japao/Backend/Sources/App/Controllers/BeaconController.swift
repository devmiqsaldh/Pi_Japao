import Vapor
import Fluent

struct BeaconController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let beacons = routes.grouped("api", "beacons")
        beacons.get(use: index)
        beacons.post(use: create)
        beacons.group(":beaconID") { beacon in
            beacon.get(use: show)
            beacon.put(use: update)
            beacon.delete(use: delete)
        }
    }
    
    func index(req: Request) async throws -> [Beacon.Public] {
        try await Beacon.query(on: req.db)
            .all()
            .map { $0.toPublic() }
    }
    
    func create(req: Request) async throws -> Beacon.Public {
        let create = try req.content.decode(Beacon.Create.self)
        
        // Verificar se já existe beacon com mesmo UUID
        if try await Beacon.query(on: req.db)
            .filter(\.$beaconID == create.beaconID)
            .first() != nil {
            throw Abort(.conflict, reason: "Beacon com UUID '\(create.beaconID)' já está cadastrado")
        }
        
        // Verificar se já existe aluno usando este beacon
        let existingStudent = try await Student.query(on: req.db)
            .join(Beacon.self, on: \Student.$beacon.$id == \Beacon.$id)
            .filter(Beacon.self, \.$beaconID == create.beaconID)
            .first()
        
        if existingStudent != nil {
            throw Abort(.conflict, reason: "Este beacon já está associado a um aluno")
        }
        
        let beacon = Beacon(
            beaconID: create.beaconID,
            name: create.name,
            isActive: create.isActive ?? true
        )
        try await beacon.save(on: req.db)
        return beacon.toPublic()
    }
    
    func show(req: Request) async throws -> Beacon.Public {
        guard let beacon = try await Beacon.find(req.parameters.get("beaconID"), on: req.db) else {
            throw Abort(.notFound)
        }
        return beacon.toPublic()
    }
    
    func update(req: Request) async throws -> Beacon.Public {
        guard let beacon = try await Beacon.find(req.parameters.get("beaconID"), on: req.db) else {
            throw Abort(.notFound)
        }
        
        let update = try req.content.decode(Beacon.Update.self)
        if let name = update.name {
            beacon.name = name
        }
        if let isActive = update.isActive {
            beacon.isActive = isActive
        }
        try await beacon.save(on: req.db)
        return beacon.toPublic()
    }
    
    func delete(req: Request) async throws -> HTTPStatus {
        guard let beacon = try await Beacon.find(req.parameters.get("beaconID"), on: req.db) else {
            throw Abort(.notFound)
        }
        try await beacon.delete(on: req.db)
        return .noContent
    }
}

