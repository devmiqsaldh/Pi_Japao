import Foundation
import Observation

@Observable
class StudentViewModel {
    var students: [StudentDTO] = []
    var beacons: [BeaconDTO] = []
    var isLoading = false
    var errorMessage: String?
    
    private let apiService = APIService.shared
    
    func loadStudents() async {
        isLoading = true
        errorMessage = nil
        
        do {
            students = try await apiService.fetchStudents()
        } catch {
            errorMessage = "Erro ao carregar alunos: \(error.localizedDescription)"
            print("❌ Erro: \(error)")
        }
        
        isLoading = false
    }
    
    func loadBeacons() async {
        do {
            beacons = try await apiService.fetchBeacons()
        } catch {
            print("❌ Erro ao carregar beacons: \(error)")
        }
    }
    
    func createStudent(name: String, email: String?, phone: String?, beaconID: UUID) async throws {
        let createDTO = StudentCreateDTO(name: name, email: email, phone: phone, beaconID: beaconID)
        let created = try await apiService.createStudent(createDTO)
        await loadStudents()
    }
    
    func updateStudent(id: UUID, name: String? = nil, email: String? = nil, phone: String? = nil, beaconID: UUID? = nil) async throws {
        let updateDTO = StudentUpdateDTO(name: name, email: email, phone: phone, beaconID: beaconID)
        _ = try await apiService.updateStudent(id: id, updateDTO)
        await loadStudents()
    }
    
    func deleteStudent(id: UUID) async throws {
        try await apiService.deleteStudent(id: id)
        await loadStudents()
    }
}

