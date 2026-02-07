//
//  LocationService.swift
//  UrbanMedic
//
//  Created by Demain Petropavlov on 02.02.2026.
//

import Foundation
import CoreLocation

final class LocationService: NSObject, LocationProviding {

    private let locationManager = CLLocationManager()
    private let networkManager: NetworkManaging
    private var locationContinuation: CheckedContinuation<CLLocation, Error>?
    private var isRequestInProgress = false

    init(networkManager: NetworkManaging) {
        self.networkManager = networkManager
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyKilometer
    }

    // MARK: - Public Methods

    func requestPermission() {
        if locationManager.authorizationStatus == .notDetermined {
            locationManager.requestWhenInUseAuthorization()
        }
    }

    func requestLocation() async throws -> CLLocation {
        guard !isRequestInProgress else {
            throw LocationError.requestInProgress
        }

        return try await withCheckedThrowingContinuation { continuation in
            isRequestInProgress = true
            locationContinuation = continuation

            switch locationManager.authorizationStatus {
            case .notDetermined:
                locationManager.requestWhenInUseAuthorization()
            case .authorizedWhenInUse, .authorizedAlways:
                locationManager.requestLocation()
            case .restricted, .denied:
                resumeContinuation(with: .failure(LocationError.permissionDenied))
            @unknown default:
                resumeContinuation(with: .failure(LocationError.unknown))
            }
        }
    }

    func getCityName(for location: CLLocation) async throws -> String {
        let response = try await networkManager.fetchLocation(
            latitude: location.coordinate.latitude,
            longitude: location.coordinate.longitude
        )
        return response.suggestions.first?.data.cityName ?? LocalizedStrings.unknown
    }

    // MARK: - Private Methods

    private func resumeContinuation(with result: Result<CLLocation, Error>) {
        isRequestInProgress = false
        let continuation = locationContinuation
        locationContinuation = nil

        switch result {
        case .success(let location):
            continuation?.resume(returning: location)
        case .failure(let error):
            continuation?.resume(throwing: error)
        }
    }
}

// MARK: - CLLocationManagerDelegate

extension LocationService: CLLocationManagerDelegate {

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        resumeContinuation(with: .success(location))
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        resumeContinuation(with: .failure(error))
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        let status = manager.authorizationStatus

        if status == .authorizedWhenInUse || status == .authorizedAlways {
            if isRequestInProgress {
                locationManager.requestLocation()
            }
        } else if status == .denied || status == .restricted {
            if isRequestInProgress {
                resumeContinuation(with: .failure(LocationError.permissionDenied))
            }
        }
    }
}

// MARK: - Location Error

enum LocationError: Error, LocalizedError {
    case permissionDenied
    case requestInProgress
    case unknown

    var errorDescription: String? {
        switch self {
        case .permissionDenied:
            return LocalizedStrings.locationPermissionDenied
        case .requestInProgress:
            return "Location request already in progress"
        case .unknown:
            return LocalizedStrings.locationUnknownError
        }
    }
}
