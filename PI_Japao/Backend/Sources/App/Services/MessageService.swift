import Vapor
import Fluent

/// Envia as notificações de presença aos responsáveis.
///
/// Por enquanto o envio é simulado: as mensagens vão para o log do servidor.
/// Para enviar de verdade, basta trocar os dois métodos `deliver` por um
/// provedor de e-mail (ex.: SendGrid) e de WhatsApp (ex.: Twilio).
final class MessageService {
    static let shared = MessageService()

    private let logger = Logger(label: "app.messages")

    private init() {}

    func send(toEmail email: String?, phone: String?, message: String, on database: Database) async throws {
        var channels: [String] = []

        if let email, !email.isEmpty {
            deliverEmail(to: email, message: message)
            channels.append("email")
        }

        if let phone, !phone.isEmpty {
            deliverWhatsApp(to: phone, message: message)
            channels.append("whatsapp")
        }

        if channels.isEmpty {
            logger.warning("Aluno sem e-mail ou telefone; mensagem não enviada")
        } else {
            logger.info("Mensagem enviada", metadata: ["canais": .string(channels.joined(separator: ","))])
        }
    }

    // MARK: - Canais (simulados)

    private func deliverEmail(to email: String, message: String) {
        logger.info("[simulado] e-mail", metadata: ["para": .string(email), "mensagem": .string(message)])
    }

    private func deliverWhatsApp(to phone: String, message: String) {
        logger.info("[simulado] whatsapp", metadata: ["para": .string(phone), "mensagem": .string(message)])
    }
}
