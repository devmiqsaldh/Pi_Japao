import Vapor
import Fluent

struct StudentController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let students = routes.grouped("api", "students")
        students.get(use: index)
        students.post(use: create)
        students.group(":studentID") { student in
            student.get(use: show)
            student.put(use: update)
            student.delete(use: delete)
        }
    }
    
    func index(req: Request) async throws -> [Student.Public] {
        let students = try await Student.query(on: req.db)
            .with(\.$beacon)
            .all()
        return try await students.asyncMap { try await $0.toPublic(on: req.db) }
    }
    
    func create(req: Request) async throws -> Student.Public {
        let create = try req.content.decode(Student.Create.self)
        
        // Verificar se o beacon existe
        guard try await Beacon.find(create.beaconID, on: req.db) != nil else {
            throw Abort(.notFound, reason: "Beacon não encontrado")
        }
        
        let student = Student(
            name: create.name,
            email: create.email,
            phone: create.phone,
            beaconID: create.beaconID
        )
        try await student.save(on: req.db)
        try await student.$beacon.load(on: req.db)
        return try await student.toPublic(on: req.db)
    }
    
    func show(req: Request) async throws -> Student.Public {
        guard let student = try await Student.find(req.parameters.get("studentID"), on: req.db) else {
            throw Abort(.notFound)
        }
        try await student.$beacon.load(on: req.db)
        return try await student.toPublic(on: req.db)
    }
    
    func update(req: Request) async throws -> Student.Public {
        guard let student = try await Student.find(req.parameters.get("studentID"), on: req.db) else {
            throw Abort(.notFound)
        }
        
        let update = try req.content.decode(Student.Update.self)
        if let name = update.name {
            student.name = name
        }
        if let email = update.email {
            student.email = email.isEmpty ? nil : email
        }
        if let phone = update.phone {
            student.phone = phone.isEmpty ? nil : phone
        }
        if let beaconID = update.beaconID {
            // Verificar se o beacon existe
            guard try await Beacon.find(beaconID, on: req.db) != nil else {
                throw Abort(.notFound, reason: "Beacon não encontrado")
            }
            student.$beacon.id = beaconID
        }
        try await student.save(on: req.db)
        try await student.$beacon.load(on: req.db)
        return try await student.toPublic(on: req.db)
    }
    
    func delete(req: Request) async throws -> HTTPStatus {
        guard let student = try await Student.find(req.parameters.get("studentID"), on: req.db) else {
            throw Abort(.notFound)
        }
        try await student.delete(on: req.db)
        return .noContent
    }
}

extension Sequence {
    func asyncMap<T>(_ transform: (Element) async throws -> T) async rethrows -> [T] {
        var results = [T]()
        for element in self {
            try await results.append(transform(element))
        }
        return results
    }
}

