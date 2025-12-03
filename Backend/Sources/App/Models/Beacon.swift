import Foundation
import Fluent
import Vapor

final class Beacon: Model, Content {
    static let schema = "beacons"
    
    @ID(key: .id)
    var id: UUID?
    
    @Field(key: "beacon_id")
    var beaconID: String
    
    @Field(key: "name")
    var name: String
    
    @Field(key: "is_active")
    var isActive: Bool
    
    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?
    
    @Timestamp(key: "updated_at", on: .update)
    var updatedAt: Date?
    
    @Children(for: \.$beacon)
    var students: [Student]
    
    init() {}
    
    init(id: UUID? = nil, beaconID: String, name: String, isActive: Bool = true) {
        self.id = id
        self.beaconID = beaconID
        self.name = name
        self.isActive = isActive
    }
}

extension Beacon {
    struct Create: Content {
        var beaconID: String
        var name: String
        var isActive: Bool?
    }
    
    struct Update: Content {
        var name: String?
        var isActive: Bool?
    }
    
    struct Public: Content {
        var id: UUID?
        var beaconID: String
        var name: String
        var isActive: Bool
        var createdAt: Date?
        var updatedAt: Date?
    }
    
    func toPublic() -> Public {
        Public(
            id: id,
            beaconID: beaconID,
            name: name,
            isActive: isActive,
            createdAt: createdAt,
            updatedAt: updatedAt
        )
    }
}

