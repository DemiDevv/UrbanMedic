//
//  UrbanMedicApp.swift
//  UrbanMedic
//
//  Created by Demain Petropavlov on 31.01.2026.
//

import SwiftUI

@main
struct UrbanMedicApp: App {

    @StateObject private var appState = AppState.shared

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(appState)
        }
    }
}
