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
            throw NSError(domain: "StudentError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Erro ao criar beacon: UUID não retornado"])
        }
        
        // Criar aluno associado ao beacon
        let createDTO = StudentCreateDTO(name: name, email: email, phone: phone, beaconID: beaconUUID)
        let createdStudent = try await apiService.createStudent(createDTO)
        
        // Recarregar lista de alunos para garantir que está atualizada
        try await loadStudents()
        
        // Verificar se o aluno foi realmente criado
        if !students.contains(where: { $0.id == createdStudent.id }) {
            // Se não estiver na lista, forçar recarregamento novamente
            try await loadStudents()
        }
    }
    
    func updateStudent(id: UUID, name: String? = nil, email: String? = nil, phone: String? = nil, beaconID: UUID? = nil) async throws {
        let updateDTO = StudentUpdateDTO(name: name, email: email, phone: phone, beaconID: beaconID)
        let updatedStudent = try await apiService.updateStudent(id: id, updateDTO)
        
        // Recarregar lista de alunos para garantir que está atualizada
        try await loadStudents()
        
        // Verificar se o aluno foi realmente atualizado
        if !students.contains(where: { $0.id == updatedStudent.id }) {
            // Se não estiver na lista, forçar recarregamento novamente
            try await loadStudents()
        }
    }
    
    func deleteStudent(id: UUID) async throws {
        try await apiService.deleteStudent(id: id)
        try await loadStudents()
    }
}

