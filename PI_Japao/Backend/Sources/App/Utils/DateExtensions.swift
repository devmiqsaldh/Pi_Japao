import Foundation

extension Date {
    func stripTime() -> Date {
        let cal = Calendar.current
        return cal.startOfDay(for: self)
    }
    
    func aligned(to day: Date) -> Date {
        let cal = Calendar.current
        let comps = cal.dateComponents([.hour, .minute, .second], from: self)
        return cal.date(bySettingHour: comps.hour ?? 0, minute: comps.minute ?? 0, second: comps.second ?? 0, of: day) ?? day
    }
}

extension Sequence {
    func asyncMap<T>(_ transform: (Element) async throws -> T) async rethrows -> [T] {
        var results = [T]()
        for element in self {
            try await results.append(transform(element))
        }
        return results
    }
}

