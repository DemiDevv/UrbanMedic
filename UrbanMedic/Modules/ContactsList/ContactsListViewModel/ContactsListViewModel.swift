//
//  ContactsListViewModel.swift
//  UrbanMedic
//
//  Created by Demain Petropavlov on 01.02.2026.
//

import Foundation
import Combine

@MainActor
final class ContactsListViewModel: ObservableObject {

    @Published var selectedLanguage: AuthViewModel.Language = .ru
    @Published var cityName: String = "Неизвестно"
    @Published var contacts: [ContactModel] = []
    @Published var isLoading: Bool = false
    @Published var showLogoutAlert: Bool = false
    @Published var shouldNavigateToAddContact: Bool = false
    @Published var contactToEdit: ContactModel?

    private var currentSeed: String = ""
    private var currentPage: Int = 1
    private var canLoadMore: Bool = true
    private var loadingTask: Task<Void, Never>?

    // MARK: - Initialization

    init() {
        loadSession()
        loadUserCreatedContacts()
        Task {
            await loadContactsFromAPI()
        }
    }

    // MARK: - Load Session

    private func loadSession() {
        guard let session = CoreDataManager.shared.getCurrentSession() else {
            return
        }

        currentSeed = session.seed ?? ""
        cityName = session.cityName ?? "Неизвестно"
    }

    // MARK: - Load User Created Contacts

    private func loadUserCreatedContacts() {
        let userContacts = CoreDataManager.shared.getUserCreatedContacts(for: currentSeed)
        contacts = userContacts
    }

    // MARK: - Load Contacts from API

    func loadContactsFromAPI() async {
        guard !isLoading, canLoadMore else { return }

        isLoading = true

        do {
            let response = try await NetworkManager.shared.fetchUsers(
                results: 20,
                page: currentPage,
                seed: currentSeed
            )

            let newContacts = response.results.map { $0.toDomainModel() }

            // Добавляем новые контакты после пользовательских
            let userCreatedContacts = contacts.filter { $0.isUserCreated }
            let apiContacts = contacts.filter { !$0.isUserCreated }

            contacts = userCreatedContacts + apiContacts + newContacts
            currentPage += 1
            isLoading = false
        } catch {
            print("Error loading contacts: \(error.localizedDescription)")
            canLoadMore = false
            isLoading = false
        }
    }

    // MARK: - Pagination

    func loadMoreContactsIfNeeded(currentContact: ContactModel) {
        // Проверяем, дошли ли до последнего контакта
        guard let lastContact = contacts.last,
              lastContact.id == currentContact.id else {
            return
        }

        Task {
            await loadContactsFromAPI()
        }
    }

    // MARK: - Logout

    func logout() {
        showLogoutAlert = true
    }

    func confirmLogout() {
        // Удаляем все данные
        CoreDataManager.shared.clearAllData()

        // Navigate to auth screen
        AppState.shared.logout()
    }

    // MARK: - Add Contact

    func addContactTapped() {
        contactToEdit = nil
        shouldNavigateToAddContact = true
    }

    // MARK: - Edit Contact

    func editContact(_ contact: ContactModel) {
        contactToEdit = contact
        shouldNavigateToAddContact = true
    }

    // MARK: - Refresh Contacts

    func refreshContacts() {
        // Обновляем список после добавления/редактирования
        loadUserCreatedContacts()

        // Сбрасываем API контакты и загружаем заново
        let userCreatedContacts = contacts.filter { $0.isUserCreated }
        contacts = userCreatedContacts

        currentPage = 1
        canLoadMore = true

        Task {
            await loadContactsFromAPI()
        }
    }
}
