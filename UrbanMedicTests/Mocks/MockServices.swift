//
//  MockServices.swift
//  UrbanMedicTests
//

import Foundation
import CoreData
import CoreLocation
@testable import UrbanMedic

// MARK: - Mock Data Manager

final class MockDataManager: DataManaging {

    private var mockSession: MockSession?
    var savedContacts: [ContactModel] = []
    var userCreatedContacts: [ContactModel] = []
    var clearAllDataCalled = false
    var saveSessionCalled = false
    var lastSavedSeed: String?
    var lastSavedCityName: String?

    // In-memory Core Data stack for tests
    private lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "UrbanMedic")
        let description = NSPersistentStoreDescription()
        description.type = NSInMemoryStoreType
        container.persistentStoreDescriptions = [description]
        container.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Failed to load in-memory store: \(error)")
            }
        }
        return container
    }()

    private var context: NSManagedObjectContext {
        persistentContainer.viewContext
    }

    struct MockSession {
        let seed: String
        let cityName: String?
    }

    func setMockSession(seed: String, cityName: String?) {
        // Clear existing sessions first
        let request = NSFetchRequest<UserSessionEntity>(entityName: "UserSessionEntity")
        if let existingSessions = try? context.fetch(request) {
            existingSessions.forEach { context.delete($0) }
        }

        mockSession = MockSession(seed: seed, cityName: cityName)

        // Create real entity for tests that need it
        let session = UserSessionEntity(context: context)
        session.seed = seed
        session.cityName = cityName
        session.lastLoginDate = Date()
        try? context.save()
    }

    func getCurrentSession() -> UserSessionEntity? {
        let request = NSFetchRequest<UserSessionEntity>(entityName: "UserSessionEntity")
        return try? context.fetch(request).first
    }

    func saveSession(seed: String, cityName: String?) {
        saveSessionCalled = true
        lastSavedSeed = seed
        lastSavedCityName = cityName
        mockSession = MockSession(seed: seed, cityName: cityName)
    }

    func saveContact(_ contact: ContactModel, seed: String) {
        savedContacts.append(contact)
    }

    func updateContact(_ contact: ContactModel, seed: String) {
        if let index = savedContacts.firstIndex(where: { $0.id == contact.id }) {
            savedContacts[index] = contact
        }
    }

    func getUserCreatedContacts(for seed: String) -> [ContactModel] {
        return userCreatedContacts
    }

    func updateSessionCityName(_ cityName: String) {
        lastSavedCityName = cityName
    }

    func clearAllData() {
        clearAllDataCalled = true
        savedContacts.removeAll()
        userCreatedContacts.removeAll()
        mockSession = nil
    }
}

// MARK: - Mock Network Manager

final class MockNetworkManager: NetworkManaging {

    var usersToReturn: UserResponse?
    var locationToReturn: LocationResponse?
    var shouldThrowError: Error?
    var fetchUsersCalled = false
    var fetchLocationCalled = false

    func fetchUsers(results: Int, page: Int, seed: String) async throws -> UserResponse {
        fetchUsersCalled = true

        if let error = shouldThrowError {
            throw error
        }

        return usersToReturn ?? UserResponse(
            results: [],
            info: ResponseInfo(seed: seed, results: results, page: page)
        )
    }

    func fetchLocation(latitude: Double, longitude: Double) async throws -> LocationResponse {
        fetchLocationCalled = true

        if let error = shouldThrowError {
            throw error
        }

        return locationToReturn ?? LocationResponse(suggestions: [])
    }
}

// MARK: - Mock Location Service

final class MockLocationService: LocationProviding {

    var requestPermissionCalled = false
    var requestLocationCalled = false
    var getCityNameCalled = false

    var locationToReturn: CLLocation = CLLocation(latitude: 55.7558, longitude: 37.6173)
    var cityNameToReturn: String = "Москва"
    var shouldThrowError: Error?

    func requestPermission() {
        requestPermissionCalled = true
    }

    func requestLocation() async throws -> CLLocation {
        requestLocationCalled = true

        if let error = shouldThrowError {
            throw error
        }

        return locationToReturn
    }

    func getCityName(for location: CLLocation) async throws -> String {
        getCityNameCalled = true

        if let error = shouldThrowError {
            throw error
        }

        return cityNameToReturn
    }
}

// MARK: - Mock Notification Service

final class MockNotificationService: NotificationProviding {

    var requestPermissionCalled = false
    var sendNotificationCalled = false
    var permissionGranted = true
    var lastNotificationTitle: String?
    var lastNotificationBody: String?

    func requestPermission(completion: @escaping (Bool) -> Void) {
        requestPermissionCalled = true
        completion(permissionGranted)
    }

    func sendLocalNotification(title: String, body: String?) {
        sendNotificationCalled = true
        lastNotificationTitle = title
        lastNotificationBody = body
    }
}

// MARK: - Mock Vibration Service

final class MockVibrationService: VibrationProviding {

    var triggerVibrationCalled = false

    func triggerVibration() {
        triggerVibrationCalled = true
    }
}

// MARK: - Mock App State

final class MockAppState: AppStateProtocol {

    var isAuthenticated: Bool = false
    var selectedLanguage: Language = .ru

    var loginCalled = false
    var logoutCalled = false
    var checkAuthenticationCalled = false

    func login() {
        loginCalled = true
        isAuthenticated = true
    }

    func logout() {
        logoutCalled = true
        isAuthenticated = false
    }

    func checkAuthentication() {
        checkAuthenticationCalled = true
    }
}


// MARK: - Test Errors

enum TestError: Error, LocalizedError {
    case networkError
    case locationError
    case timeout

    var errorDescription: String? {
        switch self {
        case .networkError: return "Network error"
        case .locationError: return "Location error"
        case .timeout: return "Timeout error"
        }
    }
}
