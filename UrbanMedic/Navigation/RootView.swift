//
//  RootView.swift
//  UrbanMedic
//
//  Created by Demain Petropavlov on 02.02.2026.
//

import SwiftUI

struct RootView: View {

    @EnvironmentObject private var appState: AppState

    var body: some View {
        Group {
            if appState.isAuthenticated {
                ContactsListView()
            } else {
                AuthView()
            }
        }
        .animation(.easeInOut(duration: 0.3), value: appState.isAuthenticated)
    }
}
