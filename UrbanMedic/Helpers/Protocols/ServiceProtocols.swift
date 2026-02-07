//
//  ServiceProtocols.swift
//  UrbanMedic
//

import Foundation
import CoreLocation

// MARK: - Data Managing

protocol DataManaging {
    func getCurrentSession() -> UserSessionEntity?
    func saveSession(seed: String, cityName: String?)
    func saveContact(_ contact: ContactModel, seed: String)
    func updateContact(_ contact: ContactModel, seed: String)
    func getUserCreatedContacts(for seed: String) -> [ContactModel]
    func updateSessionCityName(_ cityName: String)
    func clearAllData()
}

// MARK: - Network Managing

protocol NetworkManaging {
    func fetchUsers(results: Int, page: Int, seed: String) async throws -> UserResponse
    func fetchLocation(latitude: Double, longitude: Double) async throws -> LocationResponse
}

// MARK: - Location Providing

protocol LocationProviding {
    func requestPermission()
    func requestLocation() async throws -> CLLocation
    func getCityName(for location: CLLocation) async throws -> String
}

// MARK: - Notification Providing

protocol NotificationProviding {
    func requestPermission(completion: @escaping (Bool) -> Void)
    func sendLocalNotification(title: String, body: String?)
}

// MARK: - Vibration Providing

protocol VibrationProviding {
    func triggerVibration()
}

// MARK: - App State Protocol

protocol AppStateProtocol: AnyObject {
    var isAuthenticated: Bool { get set }
    var selectedLanguage: Language { get set }
    func login()
    func logout()
    func checkAuthentication()
}
