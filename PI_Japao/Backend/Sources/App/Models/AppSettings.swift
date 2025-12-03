import Foundation
import Fluent
import Vapor

final class AppSettings: Model, Content {
    static let schema = "app_settings"
    
    @ID(key: .id)
    var id: UUID?
    
    @Field(key: "presence_start")
    var presenceStart: Date
    
    @Field(key: "presence_cutoff")
    var presenceCutoff: Date
    
    @Field(key: "exit_start")
    var exitStart: Date
    
    @Field(key: "exit_cutoff")
    var exitCutoff: Date
    
    @Field(key: "presence_message")
    var presenceMessage: String
    
    @Field(key: "absence_message")
    var absenceMessage: String
    
    @Field(key: "left_message")
    var leftMessage: String
    
    @Field(key: "not_left_message")
    var notLeftMessage: String
    
    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?
    
    @Timestamp(key: "updated_at", on: .update)
    var updatedAt: Date?
    
    init() {}
    
    init(
        id: UUID? = nil,
        presenceStart: Date,
        presenceCutoff: Date,
        exitStart: Date,
        exitCutoff: Date,
        presenceMessage: String,
        absenceMessage: String,
        leftMessage: String,
        notLeftMessage: String
    ) {
        self.id = id
        self.presenceStart = presenceStart
        self.presenceCutoff = presenceCutoff
        self.exitStart = exitStart
        self.exitCutoff = exitCutoff
        self.presenceMessage = presenceMessage
        self.absenceMessage = absenceMessage
        self.leftMessage = leftMessage
        self.notLeftMessage = notLeftMessage
    }
    
    // Mensagens fixas - não podem ser alteradas
    static func fixedPresenceMessage() -> String {
        return "{name} - Presença confirmada"
    }
    
    static func fixedAbsenceMessage() -> String {
        return "{name} - Falta registrada"
    }
    
    static func fixedLeftMessage() -> String {
        return "{name} - Saída confirmada"
    }
    
    static func fixedNotLeftMessage() -> String {
        return "{name} - Não saiu"
    }
    
    static func makeDefault(for day: Date = Date()) -> AppSettings {
        let cal = Calendar.current
        let date = day.stripTime()
        let presenceStart = cal.date(bySettingHour: 8, minute: 0, second: 0, of: date)!
        let presenceCutoff = cal.date(bySettingHour: 8, minute: 30, second: 0, of: date)!
        let exitStart = cal.date(bySettingHour: 17, minute: 0, second: 0, of: date)!
        let exitCutoff = cal.date(bySettingHour: 17, minute: 30, second: 0, of: date)!
        
        return AppSettings(
            presenceStart: presenceStart,
            presenceCutoff: presenceCutoff,
            exitStart: exitStart,
            exitCutoff: exitCutoff,
            presenceMessage: fixedPresenceMessage(),
            absenceMessage: fixedAbsenceMessage(),
            leftMessage: fixedLeftMessage(),
            notLeftMessage: fixedNotLeftMessage()
        )
    }
}

extension AppSettings {
    struct Update: Content {
        var presenceStart: Date?
        var presenceCutoff: Date?
        var exitStart: Date?
        var exitCutoff: Date?
        // Mensagens removidas - são sempre fixas
    }
    
    struct Public: Content {
        var id: UUID?
        var presenceStart: Date
        var presenceCutoff: Date
        var exitStart: Date
        var exitCutoff: Date
        // Mensagens não são expostas - são sempre fixas
        var createdAt: Date?
        var updatedAt: Date?
    }
    
    func toPublic() -> Public {
        Public(
            id: id,
            presenceStart: presenceStart,
            presenceCutoff: presenceCutoff,
            exitStart: exitStart,
            exitCutoff: exitCutoff,
            createdAt: createdAt,
            updatedAt: updatedAt
        )
    }
}

