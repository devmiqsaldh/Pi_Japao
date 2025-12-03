import Vapor
import Fluent
import Foundation

class MessageService {
    static let shared = MessageService()
    
    private init() {}
    
    func send(toEmail email: String?, phone: String?, message: String, on database: Database) async throws {
        // Simular latência de envio (200ms)
        try await Task.sleep(nanoseconds: 200_000_000)
        
        // Enviar por Email e WhatsApp (ambos podem ser gratuitos)
        var sentCount = 0
        
        // Enviar Email
        if let email = email, !email.isEmpty {
            print("📧 EMAIL -> \(email): \(message)")
            // TODO: Integrar com serviço de email real (SendGrid, etc.)
            // Por enquanto apenas simula o envio
            sentCount += 1
        }
        
        // Enviar WhatsApp
        if let phone = phone, !phone.isEmpty {
            print("💬 WHATSAPP -> \(phone): \(message)")
            // TODO: Integrar com API gratuita de WhatsApp
            // Opções gratuitas:
            // - Twilio WhatsApp API (1.000 mensagens/mês grátis)
            // - Evolution API (self-hosted, gratuito)
            // Por enquanto apenas simula o envio
            sentCount += 1
        }
        
        // Verificar se pelo menos um método de contato está disponível
        if sentCount == 0 {
            print("⚠️ AVISO: Aluno sem email ou telefone cadastrado. Mensagem não enviada: \(message)")
        } else {
            print("✅ Mensagem enviada por \(sentCount) canal(is)")
        }
    }
}

