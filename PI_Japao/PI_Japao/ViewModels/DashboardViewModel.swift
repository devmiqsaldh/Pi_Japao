import Foundation
import Observation

@Observable
class DashboardViewModel {
    var currentPresenceSession: AttendanceSessionDTO?
    var currentExitSession: AttendanceSessionDTO?
    var students: [StudentDTO] = []
    var isLoading = false
    
    private let apiService = APIService.shared
    private var refreshTask: Task<Void, Never>?
    
    func start() async throws {
        try await loadCurrentSessions()
        try await loadStudents()
        startAutoRefresh()
    }
    
    func stop() {
        refreshTask?.cancel()
    }
    
    private func startAutoRefresh() {
        refreshTask?.cancel()
        refreshTask = Task {
            while !Task.isCancelled {
                try? await Task.sleep(nanoseconds: 60_000_000_000) // 60 segundos
                if !Task.isCancelled {
                    try? await loadCurrentSessions()
                }
            }
        }
    }
    
    private func loadCurrentSessions() async throws {
        isLoading = true
        defer { isLoading = false }
        
        let today = Date().stripTime()
        let sessions = try await apiService.fetchSessions(date: today)
        
        currentPresenceSession = sessions.first { $0.kind == .presence }
        currentExitSession = sessions.first { $0.kind == .exit }
    }
    
    private func loadStudents() async throws {
        students = try await apiService.fetchStudents()
    }
    
    func reportDetection(beaconID: String) async throws {
        let response = try await apiService.reportDetection(beaconID: beaconID)
        if response.success {
            try await loadCurrentSessions()
        } else {
            throw NSError(domain: "AttendanceError", code: -1, userInfo: [NSLocalizedDescriptionKey: response.message])
        }
    }
}

