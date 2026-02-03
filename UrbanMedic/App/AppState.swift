//
//  AppState.swift
//  UrbanMedic
//
//  Created by Demain Petropavlov on 02.02.2026.
//

import Foundation
import Combine

final class AppState: ObservableObject {

    static let shared = AppState()

    private enum Keys {
        static let selectedLanguage = "selectedLanguage"
    }

    @Published var isAuthenticated: Bool = false
    @Published var selectedLanguage: Language = .ru {
        didSet {
            UserDefaults.standard.set(selectedLanguage.rawValue, forKey: Keys.selectedLanguage)
        }
    }

    private init() {
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
        NotificationService.shared.requestPermission { _ in }
        LocationService.shared.requestPermission()
    }

    func checkAuthentication() {
        isAuthenticated = CoreDataManager.shared.getCurrentSession() != nil
    }

    func login() {
        isAuthenticated = true
    }

    func logout() {
        isAuthenticated = false
    }
}
