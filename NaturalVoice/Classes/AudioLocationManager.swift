//
//  AudioLocationManager.swift
//  NaturalVoice
//
//  Created by AimMatic Team on 6/10/18.
//

import Foundation
import CoreLocation

class AudioLocationManager: NSObject {

    fileprivate static let instance = AudioLocationManager()
    fileprivate var locationManager: CLLocationManager!
    var location = AudioLocation(lat: 0, lng: 0)
    
    static var shared: AudioLocationManager {
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

extension AudioLocationManager: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = manager.location {
            let coordinate = location.coordinate
            self.location = AudioLocation(lat: coordinate.latitude, lng: coordinate.longitude)
        }
    }
}
