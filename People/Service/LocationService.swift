//
//  LocationService.swift
//  People
//
//  Created by Andrey on 10.03.2023.
//

import CoreLocation
import Swinject

class LocationService: NSObject {
    
    let locationManager = CLLocationManager()
    
    var premissionStatus: PermissionStatus {
        switch locationManager.authorizationStatus {
        case .notDetermined:
            return .needToRequest
        case .restricted:
            return .denied
        case .denied:
            return .denied
        case .authorizedAlways:
            return .ok
        case .authorizedWhenInUse:
            return .ok
        @unknown default:
            return .needToRequest
        }
    }
    
    // MARK: Published properties
    
    @Published var location: CLLocation?
    @Published var locationStatus: LocationStatus = .initial
    
    // MARK: - Initializers
    
    override convenience init() {
        self.init(container: .defaultContainer)
    }
    
    init(container: Container) {
        super.init()
        
        locationManager.delegate = self
    }
    
    // MARK: - Location methods
    
    func startUpdatingLocation(delegate: LocationServiceDelegate) {
        switch premissionStatus {
        case .needToRequest:
            locationManager.requestWhenInUseAuthorization()
        case .denied:
            delegate.openLocationSettings()
        default:
            break
        }
        locationManager.startUpdatingLocation()
    }
    
    func stopUpdatingLocation() {
        locationManager.stopUpdatingLocation()
        locationStatus = .initial
    }
    
    // MARK: Location status
    
    private func updateLocationStatus() {
        switch locationManager.authorizationStatus {
        case .notDetermined:
            locationStatus = .noPermission
        case .restricted:
            locationStatus = .noPermission
        case .denied:
            locationStatus = .noPermission
        case .authorizedAlways:
            locationStatus = .notStarted
        case .authorizedWhenInUse:
            locationStatus = .notStarted
        @unknown default:
            locationStatus = .noPermission
        }
    }
}

// MARK: - CLLocationManagerDelegate
extension LocationService: CLLocationManagerDelegate {
    
    func locationManager(
        _ manager: CLLocationManager,
        didUpdateLocations locations: [CLLocation]
    ) {
        self.location = locations.first
    }
    
    func locationManager(
        _ manager: CLLocationManager,
        didFailWithError error: Error
    ) {
        print("error \(error.localizedDescription)")
    }
    
    func locationManager(
        _ manager: CLLocationManager,
        didChangeAuthorization status: CLAuthorizationStatus
    ) {
        updateLocationStatus()
    }
}

// MARK: - Status enums
extension LocationService {
    
    enum PermissionStatus {
        case ok
        case needToRequest
        case denied
    }
    
    enum LocationStatus {
        case ok
        case notStarted
        case noPermission
        
        static let initial = LocationStatus.notStarted
    }
}
