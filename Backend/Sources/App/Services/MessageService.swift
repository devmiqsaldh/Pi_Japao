import Vapor
import Fluent
import Foundation

class MessageService {
    static let shared = MessageService()
    
    private init() {}
    
    func send(toEmail email: String?, phone: String?, message: String, on database: Database) async throws {
        // Simular latência de envio (200ms)
        try await Task.sleep(nanoseconds: 200_000_000)
        
        // Aqui você pode integrar com serviços reais de SMS/Email
        // Por exemplo: Twilio para SMS, SendGrid para Email
        
        if let email = email, !email.isEmpty {
            print("📧 EMAIL -> \(email): \(message)")
            // TODO: Integrar com serviço de email real
        }
        
        if let phone = phone, !phone.isEmpty {
            print("📱 SMS -> \(phone): \(message)")
            // TODO: Integrar com serviço de SMS real (ex: Twilio)
        }
        
        // Log no banco de dados (opcional)
        // Você pode criar uma tabela de logs de mensagens se necessário
    }
}

