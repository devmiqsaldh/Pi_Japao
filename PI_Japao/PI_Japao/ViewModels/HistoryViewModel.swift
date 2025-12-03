import Foundation
import Observation

@Observable
class HistoryViewModel {
    var sessions: [AttendanceSessionDTO] = []
    var isLoading = false
    var errorMessage: String?
    
    private let apiService = APIService.shared
    
    func loadSessions() async {
        isLoading = true
        errorMessage = nil
        
        do {
            sessions = try await apiService.fetchSessions()
        } catch {
            errorMessage = "Erro ao carregar histórico: \(error.localizedDescription)"
            print("❌ Erro: \(error)")
        }
        
        isLoading = false
    }
    
    func loadSessionDetail(id: UUID) async throws -> SessionDetailDTO {
        return try await apiService.fetchSessionDetail(id: id)
    }
}

