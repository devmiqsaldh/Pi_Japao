import Foundation
import Observation

@Observable
class HistoryViewModel {
    var sessions: [AttendanceSessionDTO] = []
    var isLoading = false
    
    private let apiService = APIService.shared
    
    func loadSessions() async throws {
        isLoading = true
        defer { isLoading = false }
        
        do {
            sessions = try await apiService.fetchSessions()
        } catch {
            throw error
        }
    }
    
    func loadSessionDetail(id: UUID) async throws -> SessionDetailDTO {
        return try await apiService.fetchSessionDetail(id: id)
    }
}

