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
        if let apiError = error as? APIError {
            switch apiError {
            case .networkError:
                show("Erro de rede. Verifique sua conexão com a internet.", type: .error)
            case .invalidURL:
                show("URL do backend inválida. Configure nas Configurações.", type: .warning)
            case .httpError(let code):
                if code == 404 {
                    show("Recurso não encontrado no servidor.", type: .error)
                } else if code >= 500 {
                    show("Erro no servidor. Tente novamente mais tarde.", type: .error)
                } else {
                    show("Erro do servidor (código \(code)).", type: .error)
                }
            case .decodingError:
                show("Erro ao processar resposta do servidor.", type: .error)
            case .invalidResponse:
                show("Resposta inválida do servidor.", type: .error)
            }
        } else {
            show("Erro: \(error.localizedDescription)", type: .error)
        }
    }
}
