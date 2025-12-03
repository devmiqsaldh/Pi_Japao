import Foundation
import Observation

@Observable
class StudentViewModel {
    var students: [StudentDTO] = []
    var beacons: [BeaconDTO] = []
    var isLoading = false
    
    private let apiService = APIService.shared
    
    func loadStudents() async throws {
        isLoading = true
        defer { isLoading = false }
        
        do {
            students = try await apiService.fetchStudents()
        } catch {
            throw error
        }
    }
    
    func loadBeacons() async throws {
        do {
            beacons = try await apiService.fetchBeacons()
        } catch {
            throw error
        }
    }
    
    func createStudent(name: String, email: String?, phone: String?, beaconID: UUID) async throws {
        let createDTO = StudentCreateDTO(name: name, email: email, phone: phone, beaconID: beaconID)
        _ = try await apiService.createStudent(createDTO)
        try await loadStudents()
    }
    
    func updateStudent(id: UUID, name: String? = nil, email: String? = nil, phone: String? = nil, beaconID: UUID? = nil) async throws {
        let updateDTO = StudentUpdateDTO(name: name, email: email, phone: phone, beaconID: beaconID)
        _ = try await apiService.updateStudent(id: id, updateDTO)
        try await loadStudents()
    }
    
    func deleteStudent(id: UUID) async throws {
        try await apiService.deleteStudent(id: id)
        try await loadStudents()
    }
}

