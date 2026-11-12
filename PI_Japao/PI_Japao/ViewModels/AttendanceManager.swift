import Foundation
import Observation

@Observable
final class AttendanceManager {
    private let apiService = APIService.shared
    private let beaconScanner = BeaconScannerService()
    
    var isInitialized = false
    var errorMessage: String?
    
    func initialize() async {
        guard !isInitialized else { return }
        
        // Configurar delegate do scanner
        beaconScanner.delegate = self
        
        // Solicitar autorização de localização
        beaconScanner.requestAuthorization()
        
        // Carregar beacons e iniciar scan
        await loadBeaconsAndStartScanning()
        
        isInitialized = true
    }
    
    private func loadBeaconsAndStartScanning() async {
        do {
            let beacons = try await apiService.fetchBeacons()
            let activeBeaconIDs = beacons
                .filter { $0.isActive }
                .map { $0.beaconID }
            
            if !activeBeaconIDs.isEmpty {
                beaconScanner.startScanning(for: activeBeaconIDs)
            }
        } catch {
            errorMessage = "Erro ao carregar beacons: \(error.localizedDescription)"
            Log.attendance.error("Falha ao inicializar: \(error.localizedDescription)")
        }
    }
    
    func refreshBeacons() async {
        await loadBeaconsAndStartScanning()
    }
}

extension AttendanceManager: BeaconScannerServiceDelegate {
    func didDetectBeacon(beaconID: String) {
        Task {
            do {
                let response = try await apiService.reportDetection(beaconID: beaconID)
                if response.success {
                    Log.attendance.info("Deteção registada: \(response.message)")
                } else {
                    Log.attendance.notice("Deteção não processada: \(response.message)")
                }
            } catch {
                Log.attendance.error("Falha ao reportar deteção: \(error.localizedDescription)")
            }
        }
    }
}

