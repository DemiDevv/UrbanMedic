//
//  RootView.swift
//  UrbanMedic
//
//  Created by Demain Petropavlov on 02.02.2026.
//

import SwiftUI

struct RootView: View {
    @State private var isAuthenticated: Bool = false

    var body: some View {
        Group {
            if isAuthenticated {
                ContactsListView()
            } else {
                AuthView()
            }
        }
        .onAppear {
            checkAuthentication()
        }
    }

    private func checkAuthentication() {
        isAuthenticated = CoreDataManager.shared.getCurrentSession() != nil
    }
}
