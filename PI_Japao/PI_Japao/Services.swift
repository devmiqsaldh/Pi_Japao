import Foundation
import SwiftData

protocol BeaconScanner: Sendable {
    var onDetect: ((String) -> Void)? { get set }
    func start()
    func stop()
    func simulateDetect(id: String)
}

final class BeaconScannerMock: BeaconScanner {
    var onDetect: ((String) -> Void)?
    private var isRunning = false

    func start() {
        isRunning = true
    }

    func stop() {
        isRunning = false
    }

    func simulateDetect(id: String) {
        guard isRunning else { return }
        onDetect?(id)
    }
}

protocol MessageSender: Sendable {
    func send(toEmail email: String?, phone: String?, message: String) async
}

struct MessageSenderMock: MessageSender {
    func send(toEmail email: String?, phone: String?, message: String) async {
        // Simula latência
        try? await Task.sleep(nanoseconds: 200_000_000)
        // No mock, apenas loga no console
        print("Mock SEND -> email: \(email ?? "-"), phone: \(phone ?? "-"), msg: \(message)")
    }
}
