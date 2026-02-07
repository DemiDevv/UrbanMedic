//
//  AppState.swift
//  UrbanMedic
//
//  Created by Demain Petropavlov on 02.02.2026.
//

import Foundation
import Combine

final class AppState: ObservableObject, AppStateProtocol {

    private enum Keys {
        static let selectedLanguage = "selectedLanguage"
    }

    @Published var isAuthenticated: Bool = false
    @Published var selectedLanguage: Language = .ru {
        didSet {
            UserDefaults.standard.set(selectedLanguage.rawValue, forKey: Keys.selectedLanguage)
        }
    }

    private let dataManager: DataManaging
    private let notificationService: NotificationProviding
    private let locationService: LocationProviding

    init(
        dataManager: DataManaging,
        notificationService: NotificationProviding,
        locationService: LocationProviding
    ) {
        self.dataManager = dataManager
        self.notificationService = notificationService
        self.locationService = locationService
        loadSavedLanguage()
        checkAuthentication()
        requestPermissions()
    }

    private func loadSavedLanguage() {
        if let savedLanguage = UserDefaults.standard.string(forKey: Keys.selectedLanguage),
           let language = Language(rawValue: savedLanguage) {
            selectedLanguage = language
        }
    }

    private func requestPermissions() {
        notificationService.requestPermission { _ in }
        locationService.requestPermission()
    }

    func checkAuthentication() {
        isAuthenticated = dataManager.getCurrentSession() != nil
    }

    func login() {
        isAuthenticated = true
    }

    func logout() {
        isAuthenticated = false
    }
}
