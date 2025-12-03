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
    
    func createStudentWithBeacon(name: String, email: String?, phone: String?, beaconID: String, beaconName: String) async throws {
        // Criar beacon primeiro, depois criar aluno
        let beaconCreateDTO = BeaconCreateDTO(beaconID: beaconID, name: beaconName, isActive: true)
        let createdBeacon = try await apiService.createBeacon(beaconCreateDTO)
        
        guard let beaconUUID = createdBeacon.id else {
            throw NSError(domain: "StudentError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Erro ao criar beacon"])
        }
        
        // Criar aluno associado ao beacon
        let createDTO = StudentCreateDTO(name: name, email: email, phone: phone, beaconID: beaconUUID)
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

