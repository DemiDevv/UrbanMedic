//
//  DependencyContainer.swift
//  UrbanMedic
//

import Foundation
import Combine

final class DependencyContainer: ObservableObject {

    // MARK: - Services

    let dataManager: DataManaging
    let networkManager: NetworkManaging
    let locationService: LocationProviding
    let notificationService: NotificationProviding
    let vibrationService: VibrationProviding
    let appState: AppState

    // MARK: - Initialization

    init(
        dataManager: DataManaging? = nil,
        networkManager: NetworkManaging? = nil,
        locationService: LocationProviding? = nil,
        notificationService: NotificationProviding? = nil,
        vibrationService: VibrationProviding? = nil
    ) {
        // Create services with dependencies
        let network = networkManager ?? NetworkManager()
        let data = dataManager ?? CoreDataManager()
        let notification = notificationService ?? NotificationService()
        let location = locationService ?? LocationService(networkManager: network)
        let vibration = vibrationService ?? VibrationService()

        self.networkManager = network
        self.dataManager = data
        self.notificationService = notification
        self.locationService = location
        self.vibrationService = vibration

        // AppState depends on other services
        self.appState = AppState(
            dataManager: data,
            notificationService: notification,
            locationService: location
        )
    }

    // MARK: - Factory Methods

    func makeAuthViewModel() -> AuthViewModel {
        AuthViewModel(
            dataManager: dataManager,
            locationService: locationService,
            notificationService: notificationService,
            vibrationService: vibrationService,
            appState: appState
        )
    }

    func makeContactsListViewModel() -> ContactsListViewModel {
        ContactsListViewModel(
            dataManager: dataManager,
            networkManager: networkManager,
            locationService: locationService,
            appState: appState
        )
    }

    func makeAddEditContactViewModel(mode: AddEditContactView.Mode) -> AddEditContactViewModel {
        AddEditContactViewModel(mode: mode, dataManager: dataManager)
    }
}
