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
    @Published var cityName: String = "Неизвестно"
    @Published var contacts: [ContactModel] = []
    @Published var isLoading: Bool = false
    @Published var showLogoutAlert: Bool = false
    @Published var shouldNavigateToAddContact: Bool = false
    @Published var contactToEdit: ContactModel?

    private var currentSeed: String = ""
    private var currentPage: Int = 1
    private var canLoadMore: Bool = true
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Initialization

    init() {
        loadSession()
        loadUserCreatedContacts()
        loadContactsFromAPI()
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

    func loadContactsFromAPI() {
        guard !isLoading, canLoadMore else { return }

        isLoading = true

        NetworkManager.shared.fetchUsers(results: 20, page: currentPage, seed: currentSeed)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                guard let self = self else { return }
                self.isLoading = false

                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    print("Error loading contacts: \(error.localizedDescription)")
                    self.canLoadMore = false
                }
            } receiveValue: { [weak self] response in
                guard let self = self else { return }

                let newContacts = response.results.map { $0.toDomainModel() }

                // Добавляем новые контакты после пользовательских
                let userCreatedContacts = self.contacts.filter { $0.isUserCreated }
                let apiContacts = self.contacts.filter { !$0.isUserCreated }

                self.contacts = userCreatedContacts + apiContacts + newContacts
                self.currentPage += 1
            }
            .store(in: &cancellables)
    }

    // MARK: - Pagination

    func loadMoreContactsIfNeeded(currentContact: ContactModel) {
        // Проверяем, дошли ли до последнего контакта
        guard let lastContact = contacts.last,
              lastContact.id == currentContact.id else {
            return
        }

        loadContactsFromAPI()
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

        // Перезагружаем контакты с API
        let userCreatedContacts = contacts.filter { $0.isUserCreated }
        let apiContactsCount = contacts.count - userCreatedContacts.count

        // Загружаем столько же API контактов, сколько было
        let pagesToLoad = (apiContactsCount / 20) + 1
        currentPage = 1
        canLoadMore = true

        contacts = userCreatedContacts

        for _ in 1...pagesToLoad {
            loadContactsFromAPI()
        }
    }
}
