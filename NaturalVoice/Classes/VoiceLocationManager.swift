//
//  VoiceLocationManager.swift
//  NaturalVoice
//
//  Created by AimMatic Team on 6/10/18.
//

import Foundation
import CoreLocation

class VoiceLocationManager: NSObject {

    fileprivate static let instance = VoiceLocationManager()
    fileprivate var locationManager: CLLocationManager!
    var location = VoiceLocation(lat: 0, lng: 0)
    
    static var shared: VoiceLocationManager {
        return self.instance
    }
    
    override init() {
        super.init()
        self.locationManager = CLLocationManager()
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.requestAlwaysAuthorization()
        self.locationManager.startUpdatingLocation()
    }
}

extension VoiceLocationManager: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = manager.location {
            let coordinate = location.coordinate
            self.location = VoiceLocation(lat: coordinate.latitude, lng: coordinate.longitude)
        }
    }
}
