import Foundation

enum SessionKind: String, Codable, CaseIterable {
    case presence
    case exit
}

enum AttendanceStatus: String, Codable, CaseIterable {
    case present
    case absent
    case left
    case notLeft
}

extension Date {
    func stripTime() -> Date {
        let cal = Calendar.current
        return cal.startOfDay(for: self)
    }
}
