import Foundation

class AppConfig {
    static let shared = AppConfig()
    
    private let userDefaults = UserDefaults.standard
    private let backendURLKey = "backendURL"
    
    var backendURL: String {
        get {
            if let url = userDefaults.string(forKey: backendURLKey), !url.isEmpty {
                return url
            }
            // Default para desenvolvimento local
            #if DEBUG
            return "http://localhost:8080"
            #else
            return "http://192.168.1.100:8080" // IP padrão para produção
            #endif
        }
        set {
            userDefaults.set(newValue, forKey: backendURLKey)
        }
    }
    
    private init() {}
    
    func reset() {
        userDefaults.removeObject(forKey: backendURLKey)
    }
}

