import Vapor
import Fluent
import Foundation

class MessageService {
    static let shared = MessageService()
    
    private init() {}
    
    func send(toEmail email: String?, phone: String?, message: String, on database: Database) async throws {
        // Simular latência de envio (200ms)
        try await Task.sleep(nanoseconds: 200_000_000)
        
        // Enviar apenas por Email (gratuito)
        // SMS desabilitado por enquanto (requer pagamento)
        
        if let email = email, !email.isEmpty {
            print("📧 EMAIL -> \(email): \(message)")
            // TODO: Integrar com serviço de email real (SendGrid, etc.)
            // Por enquanto apenas simula o envio
        } else {
            print("⚠️ AVISO: Aluno sem email cadastrado. Mensagem não enviada: \(message)")
        }
        
        // SMS desabilitado - requer serviço pago
        // if let phone = phone, !phone.isEmpty {
        //     print("📱 SMS -> \(phone): \(message)")
        // }
        
        // Log no banco de dados (opcional)
        // Você pode criar uma tabela de logs de mensagens se necessário
    }
}

