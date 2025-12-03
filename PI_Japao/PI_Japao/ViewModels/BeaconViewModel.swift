import Foundation
import Observation

@Observable
class BeaconViewModel {
    var beacons: [BeaconDTO] = []
    var isLoading = false
    
    private let apiService = APIService.shared
    
    func loadBeacons() async throws {
        isLoading = true
        defer { isLoading = false }
        
        do {
            beacons = try await apiService.fetchBeacons()
        } catch {
            throw error
        }
    }
    
    func createBeacon(beaconID: String, name: String, isActive: Bool = true) async throws {
        let createDTO = BeaconCreateDTO(beaconID: beaconID, name: name, isActive: isActive)
        _ = try await apiService.createBeacon(createDTO)
        try await loadBeacons()
    }
    
    func updateBeacon(id: UUID, name: String? = nil, isActive: Bool? = nil) async throws {
        let updateDTO = BeaconUpdateDTO(name: name, isActive: isActive)
        _ = try await apiService.updateBeacon(id: id, updateDTO)
        try await loadBeacons()
    }
    
    func deleteBeacon(id: UUID) async throws {
        try await apiService.deleteBeacon(id: id)
        try await loadBeacons()
    }
}

