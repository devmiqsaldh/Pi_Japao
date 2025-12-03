import Foundation
import Fluent
import Vapor

enum SessionKind: String, Codable {
    case presence
    case exit
}

final class AttendanceSession: Model, Content {
    static let schema = "attendance_sessions"
    
    @ID(key: .id)
    var id: UUID?
    
    @Field(key: "date")
    var date: Date
    
    @Field(key: "kind")
    var kind: SessionKind
    
    @Field(key: "start_time")
    var startTime: Date
    
    @Field(key: "cutoff_time")
    var cutoffTime: Date
    
    @Field(key: "closed_at")
    var closedAt: Date?
    
    @Children(for: \.$session)
    var records: [AttendanceRecord]
    
    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?
    
    @Timestamp(key: "updated_at", on: .update)
    var updatedAt: Date?
    
    init() {}
    
    init(id: UUID? = nil, date: Date, kind: SessionKind, startTime: Date, cutoffTime: Date, closedAt: Date? = nil) {
        self.id = id
        self.date = date.stripTime()
        self.kind = kind
        self.startTime = startTime
        self.cutoffTime = cutoffTime
        self.closedAt = closedAt
    }
}

extension AttendanceSession {
    struct Public: Content {
        var id: UUID?
        var date: Date
        var kind: SessionKind
        var startTime: Date
        var cutoffTime: Date
        var closedAt: Date?
        var recordsCount: Int?
        var createdAt: Date?
        var updatedAt: Date?
    }
    
    func toPublic() -> Public {
        Public(
            id: id,
            date: date,
            kind: kind,
            startTime: startTime,
            cutoffTime: cutoffTime,
            closedAt: closedAt,
            recordsCount: nil,
            createdAt: createdAt,
            updatedAt: updatedAt
        )
    }
}

extension Date {
    func stripTime() -> Date {
        let cal = Calendar.current
        return cal.startOfDay(for: self)
    }
}

