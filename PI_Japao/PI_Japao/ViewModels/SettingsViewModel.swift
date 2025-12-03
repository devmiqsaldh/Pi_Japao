import Foundation
import Observation

@Observable
class SettingsViewModel {
    var settings: AppSettingsDTO?
    var isLoading = false
    
    private let apiService = APIService.shared
    
    func loadSettings() async throws {
        isLoading = true
        defer { isLoading = false }
        
        do {
            settings = try await apiService.fetchSettings()
        } catch {
            throw error
        }
    }
    
    func updateSettings(
        presenceStart: Date? = nil,
        presenceCutoff: Date? = nil,
        exitStart: Date? = nil,
        exitCutoff: Date? = nil
    ) async throws {
        // Mensagens são sempre fixas - não podem ser alteradas
        let updateDTO = AppSettingsUpdateDTO(
            presenceStart: presenceStart,
            presenceCutoff: presenceCutoff,
            exitStart: exitStart,
            exitCutoff: exitCutoff
        )
        settings = try await apiService.updateSettings(updateDTO)
    }
}

