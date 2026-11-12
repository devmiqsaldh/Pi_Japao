import Foundation
import CoreLocation
import Combine

protocol BeaconScannerServiceDelegate: AnyObject {
    func didDetectBeacon(beaconID: String)
}

class BeaconScannerService: NSObject, ObservableObject {
    weak var delegate: BeaconScannerServiceDelegate?
    
    private var locationManager: CLLocationManager?
    private var monitoredRegions: Set<CLBeaconRegion> = []
    private var knownBeaconIDs: Set<String> = []
    
    @Published var isScanning = false
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined
    
    override init() {
        super.init()
        setupLocationManager()
    }
    
    private func setupLocationManager() {
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        locationManager?.desiredAccuracy = kCLLocationAccuracyBest
        authorizationStatus = locationManager?.authorizationStatus ?? .notDetermined
    }
    
    func requestAuthorization() {
        locationManager?.requestAlwaysAuthorization()
    }
    
    func startScanning(for beaconIDs: [String]) {
        guard let locationManager = locationManager else { return }
        
        // Limpar regiões anteriores
        stopScanning()
        
        knownBeaconIDs = Set(beaconIDs)
        
        // Criar região para cada beacon ID
        for beaconID in beaconIDs {
            // Converter beaconID para UUID (assumindo formato UUID)
            if let uuid = UUID(uuidString: beaconID) {
                let region = CLBeaconRegion(
                    uuid: uuid,
                    identifier: beaconID
                )
                region.notifyOnEntry = true
                region.notifyOnExit = false
                monitoredRegions.insert(region)
                locationManager.startMonitoring(for: region)
            } else {
                // Se não for UUID, tentar criar região com major/minor se disponível
                // Por enquanto, apenas logar
                Log.beacons.notice("ID de beacon inválido (não é UUID): \(beaconID)")
            }
        }
        
        isScanning = true
    }
    
    func stopScanning() {
        guard let locationManager = locationManager else { return }
        
        for region in monitoredRegions {
            locationManager.stopMonitoring(for: region)
        }
        monitoredRegions.removeAll()
        isScanning = false
    }
    
    private func handleBeaconDetection(beaconID: String) {
        // Verificar se é um beacon conhecido
        guard knownBeaconIDs.contains(beaconID) else {
            Log.beacons.debug("Beacon desconhecido ignorado: \(beaconID)")
            return
        }
        
        delegate?.didDetectBeacon(beaconID: beaconID)
    }
}

extension BeaconScannerService: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        authorizationStatus = status
        
        if status == .denied || status == .restricted {
            isScanning = false
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didStartMonitoringFor region: CLRegion) {
        Log.beacons.info("A monitorizar região \(region.identifier)")
        // Solicitar estado imediato da região
        manager.requestState(for: region)
    }
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        guard let beaconRegion = region as? CLBeaconRegion else { return }
        let beaconID = beaconRegion.identifier
        Log.beacons.info("Beacon detetado: \(beaconID)")
        handleBeaconDetection(beaconID: beaconID)
    }
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        // Não processamos saída, apenas entrada
    }
    
    func locationManager(_ manager: CLLocationManager, didDetermineState state: CLRegionState, for region: CLRegion) {
        if state == .inside {
            guard let beaconRegion = region as? CLBeaconRegion else { return }
            let beaconID = beaconRegion.identifier
            Log.beacons.info("Beacon já dentro da região: \(beaconID)")
            handleBeaconDetection(beaconID: beaconID)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, monitoringDidFailFor region: CLRegion?, withError error: Error) {
        Log.beacons.error("Falha ao monitorizar região: \(error.localizedDescription)")
    }
}

