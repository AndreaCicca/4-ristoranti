import Foundation
import CoreLocation
import Combine

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    @Published var userLocation: CLLocation?
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined
    
    private var isAuthorized: Bool {
        #if os(macOS)
        return authorizationStatus == .authorized || authorizationStatus == .authorizedAlways
        #else
        return authorizationStatus == .authorizedWhenInUse || authorizationStatus == .authorizedAlways || authorizationStatus == .authorized
        #endif
    }
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.authorizationStatus = locationManager.authorizationStatus
        
        // Se avevamo già il permesso in precedenza, fai partire subito la ricerca
        if isAuthorized {
            locationManager.startUpdatingLocation()
        }
    }
    
    func requestPermission() {
        if locationManager.authorizationStatus == .notDetermined {
            #if os(macOS)
            locationManager.requestAlwaysAuthorization()
            #else
            locationManager.requestWhenInUseAuthorization()
            #endif
        } else if isAuthorized {
            locationManager.startUpdatingLocation()
        }
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationStatus = manager.authorizationStatus
        if isAuthorized {
            locationManager.startUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        self.userLocation = location
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location manager failed: \(error.localizedDescription)")
    }
}
