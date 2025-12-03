import Foundation
import Observation

@Observable
class DashboardViewModel {
    var currentPresenceSession: AttendanceSessionDTO?
    var currentExitSession: AttendanceSessionDTO?
    var beacons: [BeaconDTO] = []
    var isLoading = false
    var errorMessage: String?
    
    private let apiService = APIService.shared
    private var refreshTask: Task<Void, Never>?
    
    func start() async {
        await loadCurrentSessions()
        await loadBeacons()
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
                    await loadCurrentSessions()
                }
            }
        }
    }
    
    private func loadCurrentSessions() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let today = Date().stripTime()
            let sessions = try await apiService.fetchSessions(date: today)
            
            currentPresenceSession = sessions.first { $0.kind == .presence }
            currentExitSession = sessions.first { $0.kind == .exit }
        } catch {
            errorMessage = "Erro ao carregar sessões: \(error.localizedDescription)"
            print("❌ Erro: \(error)")
        }
        
        isLoading = false
    }
    
    private func loadBeacons() async {
        do {
            beacons = try await apiService.fetchBeacons()
        } catch {
            print("❌ Erro ao carregar beacons: \(error)")
        }
    }
    
    func reportDetection(beaconID: String) async {
        do {
            let response = try await apiService.reportDetection(beaconID: beaconID)
            if response.success {
                await loadCurrentSessions()
            } else {
                errorMessage = response.message
            }
        } catch {
            errorMessage = "Erro ao reportar detecção: \(error.localizedDescription)"
            print("❌ Erro: \(error)")
        }
    }
}

