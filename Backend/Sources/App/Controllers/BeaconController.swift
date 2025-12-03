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
        
        // Verificar se já existe beacon com esse ID
        if let existing = try await Beacon.query(on: req.db)
            .filter(\.$beaconID == create.beaconID)
            .first() {
            throw Abort(.conflict, reason: "Beacon com ID '\(create.beaconID)' já existe")
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

