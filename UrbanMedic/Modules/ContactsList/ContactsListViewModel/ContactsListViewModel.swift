//
//  ContactsListViewModel.swift
//  UrbanMedic
//
//  Created by Demain Petropavlov on 01.02.2026.
//

import Foundation
import Combine
import CoreLocation

@MainActor
final class ContactsListViewModel: ObservableObject {

    @Published var cityName: String = ""
    @Published var contacts: [ContactModel] = []
    @Published var isLoading: Bool = false
    @Published var showLogoutAlert: Bool = false
    @Published var shouldNavigateToAddContact: Bool = false
    @Published var contactToEdit: ContactModel?

    private var currentSeed: String = ""
    private var currentPage: Int = 1
    private var canLoadMore: Bool = true

    private let dataManager: DataManaging
    private let networkManager: NetworkManaging
    private let locationService: LocationProviding
    private let appState: AppStateProtocol

    // MARK: - Initialization

    init(
        dataManager: DataManaging,
        networkManager: NetworkManaging,
        locationService: LocationProviding,
        appState: AppStateProtocol
    ) {
        self.dataManager = dataManager
        self.networkManager = networkManager
        self.locationService = locationService
        self.appState = appState

        loadSession()
        loadUserCreatedContacts()
        Task {
            await loadContactsFromAPI()
        }

        if cityName.isEmpty {
            Task {
                await fetchCityNameInBackground()
            }
        }
    }

    // MARK: - Load Session

    private func loadSession() {
        guard let session = dataManager.getCurrentSession() else {
            return
        }

        currentSeed = session.seed ?? ""
        cityName = session.cityName ?? ""
    }

    // MARK: - Fetch City Name in Background

    private func fetchCityNameInBackground() async {
        do {
            let location = try await locationService.requestLocation()
            await updateCityName(for: location)
        } catch {
            print("Location error: \(error.localizedDescription)")
        }
    }

    private func updateCityName(for location: CLLocation) async {
        do {
            let newCityName = try await locationService.getCityName(for: location)
            self.cityName = newCityName

            dataManager.updateSessionCityName(newCityName)
        } catch {
            print("Failed to fetch city name: \(error.localizedDescription)")
        }
    }

    // MARK: - Load User Created Contacts

    private func loadUserCreatedContacts() {
        let userContacts = dataManager.getUserCreatedContacts(for: currentSeed)
        contacts = userContacts
    }

    // MARK: - Load Contacts from API

    func loadContactsFromAPI() async {
        guard !isLoading, canLoadMore else { return }

        isLoading = true

        do {
            let response = try await networkManager.fetchUsers(
                results: 20,
                page: currentPage,
                seed: currentSeed
            )

            let newContacts = response.results.map { $0.toDomainModel() }

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
        dataManager.clearAllData()

        appState.logout()
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
        loadUserCreatedContacts()

        let userCreatedContacts = contacts.filter { $0.isUserCreated }
        contacts = userCreatedContacts

        currentPage = 1
        canLoadMore = true

        Task {
            await loadContactsFromAPI()
        }
    }
}
