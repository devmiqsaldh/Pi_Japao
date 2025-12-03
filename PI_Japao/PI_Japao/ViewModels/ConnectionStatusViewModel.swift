import Foundation
import Observation

@Observable
class ConnectionStatusViewModel {
    var isConnected = false
    var lastCheck: Date?
    var errorMessage: String?
    
    private let apiService = APIService.shared
    
    func checkConnection() async {
        do {
            // Tentar buscar beacons como teste de conexão
            _ = try await apiService.fetchBeacons()
            isConnected = true
            errorMessage = nil
            lastCheck = Date()
        } catch {
            isConnected = false
            if let apiError = error as? APIError {
                switch apiError {
                case .networkError:
                    errorMessage = "Erro de rede. Verifique sua conexão."
                case .invalidURL:
                    errorMessage = "URL do backend inválida. Configure nas Configurações."
                case .httpError(let code):
                    errorMessage = "Erro do servidor (código \(code)). Verifique se o backend está rodando."
                default:
                    errorMessage = "Erro ao conectar com o backend."
                }
            } else {
                errorMessage = "Não foi possível conectar ao backend."
            }
            lastCheck = Date()
        }
    }
}

