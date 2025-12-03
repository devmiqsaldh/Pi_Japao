import Foundation

enum APIError: Error {
    case invalidURL
    case invalidResponse
    case httpError(Int)
    case decodingError(Error)
    case networkError(Error)
}

class APIService {
    static let shared = APIService()
    
    private let baseURL: String
    private let session: URLSession
    
    init(baseURL: String = "http://localhost:8080") {
        self.baseURL = baseURL
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        self.session = URLSession(configuration: config)
    }
    
    // MARK: - Beacons
    
    func fetchBeacons() async throws -> [BeaconDTO] {
        let url = try makeURL(path: "/api/beacons")
        return try await performRequest(url: url, method: "GET")
    }
    
    func createBeacon(_ beacon: BeaconCreateDTO) async throws -> BeaconDTO {
        let url = try makeURL(path: "/api/beacons")
        return try await performRequest(url: url, method: "POST", body: beacon)
    }
    
    func updateBeacon(id: UUID, _ beacon: BeaconUpdateDTO) async throws -> BeaconDTO {
        let url = try makeURL(path: "/api/beacons/\(id.uuidString)")
        return try await performRequest(url: url, method: "PUT", body: beacon)
    }
    
    func deleteBeacon(id: UUID) async throws {
        let url = try makeURL(path: "/api/beacons/\(id.uuidString)")
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        let (_, response) = try await session.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw APIError.invalidResponse
        }
    }
    
    // MARK: - Students
    
    func fetchStudents() async throws -> [StudentDTO] {
        let url = try makeURL(path: "/api/students")
        return try await performRequest(url: url, method: "GET")
    }
    
    func createStudent(_ student: StudentCreateDTO) async throws -> StudentDTO {
        let url = try makeURL(path: "/api/students")
        return try await performRequest(url: url, method: "POST", body: student)
    }
    
    func updateStudent(id: UUID, _ student: StudentUpdateDTO) async throws -> StudentDTO {
        let url = try makeURL(path: "/api/students/\(id.uuidString)")
        return try await performRequest(url: url, method: "PUT", body: student)
    }
    
    func deleteStudent(id: UUID) async throws {
        let url = try makeURL(path: "/api/students/\(id.uuidString)")
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        let (_, response) = try await session.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw APIError.invalidResponse
        }
    }
    
    // MARK: - Attendance
    
    func fetchSessions(date: Date? = nil, kind: SessionKind? = nil) async throws -> [AttendanceSessionDTO] {
        var components = URLComponents(string: baseURL + "/api/attendance/sessions")!
        var queryItems: [URLQueryItem] = []
        if let date = date {
            let formatter = ISO8601DateFormatter()
            formatter.formatOptions = [.withFullDate]
            queryItems.append(URLQueryItem(name: "date", value: formatter.string(from: date)))
        }
        if let kind = kind {
            queryItems.append(URLQueryItem(name: "kind", value: kind.rawValue))
        }
        if !queryItems.isEmpty {
            components.queryItems = queryItems
        }
        guard let url = components.url else { throw APIError.invalidURL }
        return try await performRequest(url: url, method: "GET")
    }
    
    func fetchSessionDetail(id: UUID) async throws -> SessionDetailDTO {
        let url = try makeURL(path: "/api/attendance/sessions/\(id.uuidString)")
        return try await performRequest(url: url, method: "GET")
    }
    
    func fetchSettings() async throws -> AppSettingsDTO {
        let url = try makeURL(path: "/api/attendance/settings")
        return try await performRequest(url: url, method: "GET")
    }
    
    func updateSettings(_ settings: AppSettingsUpdateDTO) async throws -> AppSettingsDTO {
        let url = try makeURL(path: "/api/attendance/settings")
        return try await performRequest(url: url, method: "PUT", body: settings)
    }
    
    // MARK: - Detections
    
    func reportDetection(beaconID: String) async throws -> DetectionResponseDTO {
        let url = try makeURL(path: "/api/detections")
        let request = DetectionRequestDTO(beaconID: beaconID, timestamp: Date())
        return try await performRequest(url: url, method: "POST", body: request)
    }
    
    // MARK: - Private Helpers
    
    private func makeURL(path: String) throws -> URL {
        guard let url = URL(string: baseURL + path) else {
            throw APIError.invalidURL
        }
        return url
    }
    
    private func performRequest<T: Decodable>(
        url: URL,
        method: String,
        body: (any Encodable)? = nil
    ) async throws -> T {
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if let body = body {
            request.httpBody = try JSONEncoder().encode(body)
        }
        
        do {
            let (data, response) = try await session.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw APIError.invalidResponse
            }
            
            guard (200...299).contains(httpResponse.statusCode) else {
                throw APIError.httpError(httpResponse.statusCode)
            }
            
            // Para DELETE que retorna 204 No Content
            if httpResponse.statusCode == 204 {
                // Retornar um objeto vazio se possível
                if data.isEmpty {
                    // Tentar criar um objeto vazio do tipo T
                    // Isso pode falhar, mas é o melhor que podemos fazer
                    throw APIError.invalidResponse
                }
            }
            
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            return try decoder.decode(T.self, from: data)
        } catch let error as DecodingError {
            throw APIError.decodingError(error)
        } catch let error as APIError {
            throw error
        } catch {
            throw APIError.networkError(error)
        }
    }
}

// MARK: - DTOs

struct BeaconDTO: Codable, Identifiable {
    var id: UUID?
    var beaconID: String
    var name: String
    var isActive: Bool
    var createdAt: Date?
    var updatedAt: Date?
}

struct BeaconCreateDTO: Codable {
    var beaconID: String
    var name: String
    var isActive: Bool?
}

struct BeaconUpdateDTO: Codable {
    var name: String?
    var isActive: Bool?
}

struct StudentDTO: Codable, Identifiable {
    var id: UUID?
    var name: String
    var email: String?
    var phone: String?
    var beaconID: UUID?
    var beacon: BeaconDTO?
    var createdAt: Date?
    var updatedAt: Date?
}

struct StudentCreateDTO: Codable {
    var name: String
    var email: String?
    var phone: String?
    var beaconID: UUID
}

struct StudentUpdateDTO: Codable {
    var name: String?
    var email: String?
    var phone: String?
    var beaconID: UUID?
}

struct AttendanceSessionDTO: Codable, Identifiable {
    var id: UUID?
    var date: Date
    var kind: SessionKind
    var startTime: Date
    var cutoffTime: Date
    var closedAt: Date?
    var recordsCount: Int?
    var createdAt: Date?
    var updatedAt: Date?
}

struct AttendanceRecordDTO: Codable, Identifiable {
    var id: UUID?
    var beaconID: UUID?
    var beacon: BeaconDTO?
    var sessionID: UUID?
    var status: AttendanceStatus
    var messageLog: [String]
    var createdAt: Date?
    var updatedAt: Date?
}

struct SessionDetailDTO: Codable {
    var session: AttendanceSessionDTO
    var records: [AttendanceRecordDTO]
}

struct AppSettingsDTO: Codable {
    var id: UUID?
    var presenceStart: Date
    var presenceCutoff: Date
    var exitStart: Date
    var exitCutoff: Date
    var presenceMessage: String
    var absenceMessage: String
    var leftMessage: String
    var notLeftMessage: String
    var createdAt: Date?
    var updatedAt: Date?
}

struct AppSettingsUpdateDTO: Codable {
    var presenceStart: Date?
    var presenceCutoff: Date?
    var exitStart: Date?
    var exitCutoff: Date?
    var presenceMessage: String?
    var absenceMessage: String?
    var leftMessage: String?
    var notLeftMessage: String?
}

struct DetectionRequestDTO: Codable {
    var beaconID: String
    var timestamp: Date
}

struct DetectionResponseDTO: Codable {
    var success: Bool
    var message: String
    var beaconID: String
    var students: [String]?
}

