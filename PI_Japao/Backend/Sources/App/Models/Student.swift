import Foundation
import Fluent
import Vapor

final class Student: Model, Content {
    static let schema = "students"
    
    @ID(key: .id)
    var id: UUID?
    
    @Field(key: "name")
    var name: String
    
    @Field(key: "email")
    var email: String?
    
    @Field(key: "phone")
    var phone: String?
    
    @Parent(key: "beacon_id")
    var beacon: Beacon
    
    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?
    
    @Timestamp(key: "updated_at", on: .update)
    var updatedAt: Date?
    
    init() {}
    
    init(id: UUID? = nil, name: String, email: String? = nil, phone: String? = nil, beaconID: UUID) {
        self.id = id
        self.name = name
        self.email = email
        self.phone = phone
        self.$beacon.id = beaconID
    }
}

extension Student {
    struct Create: Content {
        var name: String
        var email: String?
        var phone: String?
        var beaconID: UUID
    }
    
    struct Update: Content {
        var name: String?
        var email: String?
        var phone: String?
        var beaconID: UUID?
    }
    
    struct Public: Content {
        var id: UUID?
        var name: String
        var email: String?
        var phone: String?
        var beaconID: UUID?
        var beacon: Beacon.Public?
        var createdAt: Date?
        var updatedAt: Date?
    }
    
    func toPublic(on database: Database) async throws -> Public {
        try await Public(
            id: id,
            name: name,
            email: email,
            phone: phone,
            beaconID: $beacon.id,
            beacon: try await $beacon.get(on: database).toPublic(),
            createdAt: createdAt,
            updatedAt: updatedAt
        )
    }
}
