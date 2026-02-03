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

    @Published var isAuthenticated: Bool = false
    @Published var selectedLanguage: Language = .ru

    private init() {
        checkAuthentication()
        requestPermissions()
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
