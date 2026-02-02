//
//  LocationService.swift
//  UrbanMedic
//
//  Created by Demain Petropavlov on 02.02.2026.
//

import Foundation
import CoreLocation
import Combine

final class LocationService: NSObject {

    static let shared = LocationService()

    private let locationManager = CLLocationManager()
    private var locationSubject = PassthroughSubject<CLLocation, Error>()

    private override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }

    // MARK: - Public Methods

    func requestLocation() -> AnyPublisher<CLLocation, Error> {
        let authorizationStatus: CLAuthorizationStatus

        if #available(iOS 14.0, *) {
            authorizationStatus = locationManager.authorizationStatus
        } else {
            authorizationStatus = CLLocationManager.authorizationStatus()
        }

        switch authorizationStatus {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .authorizedWhenInUse, .authorizedAlways:
            locationManager.requestLocation()
        case .restricted, .denied:
            locationSubject.send(completion: .failure(LocationError.permissionDenied))
        @unknown default:
            locationSubject.send(completion: .failure(LocationError.unknown))
        }

        return locationSubject.eraseToAnyPublisher()
    }

    func getCityName(for location: CLLocation) -> AnyPublisher<String, NetworkError> {
        return NetworkManager.shared.fetchLocation(
            latitude: location.coordinate.latitude,
            longitude: location.coordinate.longitude
        )
        .map { response -> String in
            return response.suggestions.first?.data.cityName ?? "Неизвестно"
        }
        .eraseToAnyPublisher()
    }
}

// MARK: - CLLocationManagerDelegate

extension LocationService: CLLocationManagerDelegate {

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        locationSubject.send(location)
        locationSubject.send(completion: .finished)
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        locationSubject.send(completion: .failure(error))
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        let authorizationStatus: CLAuthorizationStatus

        if #available(iOS 14.0, *) {
            authorizationStatus = manager.authorizationStatus
        } else {
            authorizationStatus = CLLocationManager.authorizationStatus()
        }

        if authorizationStatus == .authorizedWhenInUse || authorizationStatus == .authorizedAlways {
            locationManager.requestLocation()
        }
    }
}

// MARK: - Location Error

enum LocationError: Error, LocalizedError {
    case permissionDenied
    case unknown

    var errorDescription: String? {
        switch self {
        case .permissionDenied:
            return "Доступ к геолокации запрещен"
        case .unknown:
            return "Неизвестная ошибка геолокации"
        }
    }
}
