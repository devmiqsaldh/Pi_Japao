# 📧 Integração de Email e WhatsApp

## Status Atual

Atualmente, o sistema está **simulando** o envio de mensagens. As mensagens são apenas impressas no console do backend, mas não são realmente enviadas.

**Nota**: O sistema agora suporta envio por **Email** e **WhatsApp** (ambos podem ser gratuitos).

## Como Funciona Atualmente

No arquivo `Backend/Sources/App/Services/MessageService.swift`, o sistema:
1. Recebe email e telefone do aluno
2. Formata a mensagem com os templates configurados
3. **Simula** o envio (apenas print no console)
4. Não envia mensagens reais ainda

## Integração com Serviços Reais

Para enviar mensagens reais, você precisa integrar com serviços de terceiros:

### 📧 Email

**Opções recomendadas:**

1. **SendGrid** (Recomendado)
   - Suporta qualquer provedor (Gmail, Outlook, Yahoo, etc.)
   - API simples e confiável
   - Plano gratuito: 100 emails/dia
   - Documentação: https://docs.sendgrid.com/

2. **Amazon SES**
   - Muito econômico
   - Suporta qualquer provedor
   - Plano gratuito: 62.000 emails/mês (primeiro ano)
   - Documentação: https://docs.aws.amazon.com/ses/

3. **Mailgun**
   - Fácil de usar
   - Suporta qualquer provedor
   - Plano gratuito: 5.000 emails/mês
   - Documentação: https://documentation.mailgun.com/

### 💬 WhatsApp

**Opções recomendadas (gratuitas ou com plano gratuito):**

1. **Twilio WhatsApp API** (Recomendado - tem plano gratuito)
   - WhatsApp Business API oficial
   - Plano gratuito: 1.000 mensagens/mês
   - Suporta números de **qualquer país**
   - Documentação: https://www.twilio.com/docs/whatsapp

2. **Evolution API** (Gratuito - self-hosted)
   - API open-source para WhatsApp
   - Totalmente gratuito
   - Requer servidor próprio
   - Documentação: https://evolution-api.com/

3. **Baileys** (Gratuito)
   - Biblioteca Node.js para WhatsApp
   - Pode ser adaptada para Swift
   - Totalmente gratuito
   - Documentação: https://github.com/WhiskeySockets/Baileys

4. **WhatsApp Business Cloud API** (Meta)
   - API oficial do Meta
   - Plano gratuito limitado
   - Documentação: https://developers.facebook.com/docs/whatsapp

## Como Integrar

### Exemplo: SendGrid para Email

1. **Criar conta no SendGrid**
   - Acesse: https://sendgrid.com
   - Crie uma conta gratuita
   - Obtenha sua API Key

2. **Adicionar dependência no Backend**

Edite `Backend/Package.swift`:
```swift
dependencies: [
    // ... existentes
    .package(url: "https://github.com/vapor-community/sendgrid.git", from: "4.0.0")
]
```

3. **Atualizar MessageService.swift**

```swift
import Vapor
import SendGrid

class MessageService {
    static let shared = MessageService()
    private let sendGridAPIKey: String
    
    init() {
        // Configure sua API Key (use variável de ambiente em produção)
        self.sendGridAPIKey = ProcessInfo.processInfo.environment["SENDGRID_API_KEY"] ?? ""
    }
    
    func send(toEmail email: String?, phone: String?, message: String, on database: Database) async throws {
        // Enviar Email
        if let email = email, !email.isEmpty {
            let emailContent = SendGridEmail(
                personalizations: [.init(to: [.init(email: email)])],
                from: .init(email: "noreply@escola.com", name: "Sistema de Presença"),
                subject: "Notificação de Presença",
                content: [.init(type: .plainText, value: message)]
            )
            
            let client = SendGridClient(apiKey: sendGridAPIKey)
            try await client.send(email: emailContent)
            print("✅ Email enviado para: \(email)")
        }
        
        // Enviar SMS (exemplo com Twilio)
        if let phone = phone, !phone.isEmpty {
            // Implementar integração com Twilio aqui
            print("📱 SMS enviado para: \(phone)")
        }
    }
}
```

### Exemplo: Twilio para WhatsApp

1. **Criar conta no Twilio**
   - Acesse: https://www.twilio.com
   - Crie uma conta (plano gratuito disponível)
   - Obtenha Account SID e Auth Token
   - Configure WhatsApp Sandbox (gratuito para testes)

2. **Adicionar dependência**

```swift
dependencies: [
    .package(url: "https://github.com/twilio/twilio-swift.git", from: "1.0.0")
]
```

3. **Implementar envio de WhatsApp**

```swift
import Twilio

// No MessageService
func sendWhatsApp(to phone: String, message: String) async throws {
    let client = TwilioClient(
        accountSid: ProcessInfo.processInfo.environment["TWILIO_ACCOUNT_SID"] ?? "",
        authToken: ProcessInfo.processInfo.environment["TWILIO_AUTH_TOKEN"] ?? ""
    )
    
    // Formato: whatsapp:+5511999999999
    let whatsappNumber = phone.starts(with: "whatsapp:") ? phone : "whatsapp:\(phone)"
    
    let response = try await client.messages.create(
        body: message,
        to: whatsappNumber,
        from: ProcessInfo.processInfo.environment["TWILIO_WHATSAPP_NUMBER"] ?? "whatsapp:+14155238886" // Sandbox
    )
    
    print("✅ WhatsApp enviado: \(response.sid)")
}
```

## Formato de Telefone

Para WhatsApp funcionar internacionalmente:
- **Sempre inclua código do país**
- Formato: `+[código do país][número]`
- Exemplos:
  - Brasil: `+5511999999999`
  - EUA: `+15551234567`
  - Portugal: `+351912345678`
- **Importante**: O número deve estar cadastrado no WhatsApp

## Variáveis de Ambiente

Configure no arquivo `.env` ou variáveis de ambiente do sistema:

```bash
# SendGrid
SENDGRID_API_KEY=SG.xxxxxxxxxxxxx

# Twilio (WhatsApp)
TWILIO_ACCOUNT_SID=ACxxxxxxxxxxxxx
TWILIO_AUTH_TOKEN=xxxxxxxxxxxxx
TWILIO_WHATSAPP_NUMBER=whatsapp:+14155238886
```

## Testes

Antes de usar em produção:

1. **Teste com seu próprio email/telefone**
2. **Verifique se mensagens chegam corretamente**
3. **Teste com diferentes provedores** (Gmail, Outlook, etc.)
4. **Teste com números de diferentes países**

## Custos

### Email (SendGrid)
- **Gratuito**: 100 emails/dia
- **Essentials**: $19.95/mês - 50.000 emails
- **Pro**: $89.95/mês - 100.000 emails

### WhatsApp (Twilio)
- **Plano Gratuito**: 1.000 mensagens/mês
- **Pago**: ~$0.005 por mensagem (após o limite gratuito)
- **Brasil**: Suportado
- **Qualquer país**: Suportado

## Próximos Passos

1. Escolher serviço de Email (recomendado: SendGrid - gratuito)
2. Escolher serviço de WhatsApp (recomendado: Twilio - tem plano gratuito)
3. Criar contas e obter credenciais
4. Adicionar dependências no `Package.swift`
5. Atualizar `MessageService.swift` com integração real
6. Configurar variáveis de ambiente
7. Testar com números/emails reais
8. Monitorar custos e uso

## Nota sobre WhatsApp

O sistema agora suporta envio por **Email** e **WhatsApp**. Ambos podem ser configurados com serviços gratuitos:
- **Email**: SendGrid (100 emails/dia grátis)
- **WhatsApp**: Twilio (1.000 mensagens/mês grátis)

## Suporte

- SendGrid: https://support.sendgrid.com/
- Twilio: https://support.twilio.com/
- Documentação do projeto: Veja `README.md`

