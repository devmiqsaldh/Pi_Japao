import Foundation
import Observation
import SwiftUI

@Observable
class ErrorHandler {
    var currentError: String?
    var errorType: Toast.ToastType = .error
    var showError = false
    
    func show(_ message: String, type: Toast.ToastType = .error) {
        currentError = message
        errorType = type
        showError = true
        
        // Auto-dismiss após 5 segundos
        Task {
            try? await Task.sleep(nanoseconds: 5_000_000_000)
            if showError {
                dismiss()
            }
        }
    }
    
    func dismiss() {
        withAnimation {
            showError = false
        }
        // Limpar mensagem após animação
        Task {
            try? await Task.sleep(nanoseconds: 300_000_000)
            currentError = nil
        }
    }
    
    func handleAPIError(_ error: Error) {
        // Verificar se é um NSError com mensagem customizada do backend
        if let nsError = error as NSError?,
           nsError.domain == "APIError",
           !nsError.localizedDescription.isEmpty {
            show(nsError.localizedDescription, type: .error)
            return
        }
        
        if let apiError = error as? APIError {
            switch apiError {
            case .networkError(let underlyingError):
                let message = underlyingError.localizedDescription.contains("timed out") 
                    ? "Timeout ao conectar. Verifique se o backend está rodando."
                    : "Erro de rede. Verifique sua conexão com a internet."
                show(message, type: .error)
            case .invalidURL:
                show("URL do backend inválida. Configure nas Configurações.", type: .warning)
            case .httpError(let code):
                var message = "Erro do servidor (código \(code))."
                if code == 404 {
                    message = "Recurso não encontrado no servidor."
                } else if code == 409 {
                    message = "Conflito: Beacon ou aluno já existe. Verifique os dados."
                } else if code == 400 {
                    message = "Dados inválidos. Verifique os campos preenchidos."
                } else if code >= 500 {
                    message = "Erro no servidor. Tente novamente mais tarde."
                }
                show(message, type: .error)
            case .decodingError(let decodingError):
                let message = "Erro ao processar resposta do servidor: \(decodingError.localizedDescription)"
                show(message, type: .error)
            case .invalidResponse:
                show("Resposta inválida do servidor.", type: .error)
            }
        } else {
            let message = error.localizedDescription.isEmpty 
                ? "Erro desconhecido. Tente novamente."
                : error.localizedDescription
            show(message, type: .error)
        }
    }
}
