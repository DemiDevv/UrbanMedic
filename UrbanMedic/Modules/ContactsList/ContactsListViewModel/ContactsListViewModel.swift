//
//  ContactsListViewModel.swift
//  UrbanMedic
//
//  Created by Demain Petropavlov on 01.02.2026.
//

import Foundation
import Combine

final class ContactsListViewModel: ObservableObject {

    @Published var selectedLanguage: AuthViewModel.Language = .ru
    @Published var cityName: String = "Самара"
    @Published var contacts: [ContactModel] = []

    init() {
        loadMockData()
    }

    func logout() {
        // TODO: Implement logout
        print("Logout tapped")
    }

    func addContactTapped() {
        // TODO: Navigate to add contact
        print("Add contact tapped")
    }

    func editContact(_ contact: ContactModel) {
        // TODO: Navigate to edit contact
        print("Edit contact: \(contact.lastName)")
    }

    private func loadMockData() {
        contacts = (1...16).map { _ in
            ContactModel(lastName: "Алексеев", email: "gorodgrosh@yandex.ru")
        }
    }
}
