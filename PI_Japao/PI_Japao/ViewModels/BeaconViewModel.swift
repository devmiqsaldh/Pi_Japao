import Foundation
import Observation

@Observable
class BeaconViewModel {
    var beacons: [BeaconDTO] = []
    var isLoading = false
    var errorMessage: String?
    
    private let apiService = APIService.shared
    
    func loadBeacons() async {
        isLoading = true
        errorMessage = nil
        
        do {
            beacons = try await apiService.fetchBeacons()
        } catch {
            errorMessage = "Erro ao carregar beacons: \(error.localizedDescription)"
            print("❌ Erro: \(error)")
        }
        
        isLoading = false
    }
    
    func createBeacon(beaconID: String, name: String, isActive: Bool = true) async throws {
        let createDTO = BeaconCreateDTO(beaconID: beaconID, name: name, isActive: isActive)
        let created = try await apiService.createBeacon(createDTO)
        await loadBeacons()
    }
    
    func updateBeacon(id: UUID, name: String? = nil, isActive: Bool? = nil) async throws {
        let updateDTO = BeaconUpdateDTO(name: name, isActive: isActive)
        _ = try await apiService.updateBeacon(id: id, updateDTO)
        await loadBeacons()
    }
    
    func deleteBeacon(id: UUID) async throws {
        try await apiService.deleteBeacon(id: id)
        await loadBeacons()
    }
}

