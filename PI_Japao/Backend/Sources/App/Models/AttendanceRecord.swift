import Foundation
import Fluent
import Vapor

enum AttendanceStatus: String, Codable {
    case present
    case absent
    case left
    case notLeft
}

final class AttendanceRecord: Model, Content {
    static let schema = "attendance_records"
    
    @ID(key: .id)
    var id: UUID?
    
    @Parent(key: "beacon_id")
    var beacon: Beacon
    
    @Parent(key: "session_id")
    var session: AttendanceSession
    
    @Field(key: "status")
    var status: AttendanceStatus
    
    @Field(key: "message_log")
    var messageLog: [String]
    
    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?
    
    @Timestamp(key: "updated_at", on: .update)
    var updatedAt: Date?
    
    init() {}
    
    init(id: UUID? = nil, beaconID: UUID, sessionID: UUID, status: AttendanceStatus, messageLog: [String] = []) {
        self.id = id
        self.$beacon.id = beaconID
        self.$session.id = sessionID
        self.status = status
        self.messageLog = messageLog
    }
}

extension AttendanceRecord {
    struct Public: Content {
        var id: UUID?
        var beaconID: UUID?
        var beacon: Beacon.Public?
        var sessionID: UUID?
        var status: AttendanceStatus
        var messageLog: [String]
        var createdAt: Date?
        var updatedAt: Date?
    }
    
    func toPublic(on database: Database) async throws -> Public {
        try await Public(
            id: id,
            beaconID: $beacon.id,
            beacon: try await $beacon.get(on: database).toPublic(),
            sessionID: $session.id,
            status: status,
            messageLog: messageLog,
            createdAt: createdAt,
            updatedAt: updatedAt
        )
    }
}

