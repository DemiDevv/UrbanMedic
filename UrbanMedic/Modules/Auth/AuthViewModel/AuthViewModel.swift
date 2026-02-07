//
//  AuthViewModel.swift
//  UrbanMedic
//
//  Created by Demain Petropavlov on 01.02.2026.
//

import Foundation
import Combine
import CoreLocation

// MARK: - Timeout Error

struct TimeoutError: Error, LocalizedError {
    var errorDescription: String? { LocalizedStrings.timeoutError }
}

@MainActor
final class AuthViewModel: ObservableObject {

    @Published var seed: String = ""
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var shouldNavigateToContacts: Bool = false

    private let dataManager: DataManaging
    private let locationService: LocationProviding
    private let notificationService: NotificationProviding
    private let vibrationService: VibrationProviding
    private let appState: AppStateProtocol

    // MARK: - Initialization

    init(
        dataManager: DataManaging,
        locationService: LocationProviding,
        notificationService: NotificationProviding,
        vibrationService: VibrationProviding,
        appState: AppStateProtocol
    ) {
        self.dataManager = dataManager
        self.locationService = locationService
        self.notificationService = notificationService
        self.vibrationService = vibrationService
        self.appState = appState
        checkExistingSession()
    }

    // MARK: - Computed Properties

    var isConfirmEnabled: Bool {
        !seed.trimmingCharacters(in: .whitespaces).isEmpty && !isLoading
    }

    // MARK: - Check Existing Session

    private func checkExistingSession() {
        if let session = dataManager.getCurrentSession() {
            self.seed = session.seed ?? ""
            self.shouldNavigateToContacts = true
        }
    }

    // MARK: - Confirm Button Action

    func confirmTapped() {
        guard isConfirmEnabled else { return }

        isLoading = true
        errorMessage = nil

        Task {
            await performAuthFlow()
        }
    }

    // MARK: - Auth Flow

    private func performAuthFlow() async {
        var cityName: String?

        do {
            cityName = try await withTimeout(seconds: 10) {
                try await self.fetchCityName()
            }
        } catch {
            print("Location error: \(error.localizedDescription)")
            cityName = nil
        }

        let notificationGranted = await requestNotificationPermission()

        vibrationService.triggerVibration()

        if notificationGranted {
            notificationService.sendLocalNotification(
                title: LocalizedStrings.authSuccessNotification,
                body: nil
            )
        }

        saveSession(cityName: cityName)
    }

    // MARK: - Fetch City Name

    private func fetchCityName() async throws -> String {
        let location = try await locationService.requestLocation()
        return try await locationService.getCityName(for: location)
    }

    // MARK: - Request Notification Permission

    private func requestNotificationPermission() async -> Bool {
        await withCheckedContinuation { continuation in
            notificationService.requestPermission { granted in
                continuation.resume(returning: granted)
            }
        }
    }

    // MARK: - Timeout Helper

    private func withTimeout<T>(seconds: TimeInterval, operation: @escaping () async throws -> T) async throws -> T {
        try await withThrowingTaskGroup(of: T.self) { group in
            group.addTask {
                try await operation()
            }

            group.addTask {
                try await Task.sleep(nanoseconds: UInt64(seconds * 1_000_000_000))
                throw TimeoutError()
            }

            let result = try await group.next()!
            group.cancelAll()
            return result
        }
    }

    // MARK: - Save Session

    private func saveSession(cityName: String?) {
        dataManager.saveSession(
            seed: seed.trimmingCharacters(in: .whitespaces),
            cityName: cityName
        )

        isLoading = false
        shouldNavigateToContacts = true

        appState.login()
    }
}
