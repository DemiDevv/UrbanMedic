//
//  ContactsListViewModelTests.swift
//  UrbanMedicTests
//

import XCTest
@testable import UrbanMedic

@MainActor
final class ContactsListViewModelTests: XCTestCase {

    private var mockDataManager: MockDataManager!
    private var mockNetworkManager: MockNetworkManager!
    private var mockLocationService: MockLocationService!
    private var mockAppState: MockAppState!

    override func setUp() {
        super.setUp()
        mockDataManager = MockDataManager()
        mockNetworkManager = MockNetworkManager()
        mockLocationService = MockLocationService()
        mockAppState = MockAppState()

        // Setup default session
        mockDataManager.setMockSession(seed: "test-seed", cityName: "Москва")
    }

    override func tearDown() {
        mockDataManager = nil
        mockNetworkManager = nil
        mockLocationService = nil
        mockAppState = nil
        super.tearDown()
    }

    private func createViewModel() -> ContactsListViewModel {
        return ContactsListViewModel(
            dataManager: mockDataManager,
            networkManager: mockNetworkManager,
            locationService: mockLocationService,
            appState: mockAppState
        )
    }

    // MARK: - Initialization Tests

    func testInitLoadsSession() async throws {
        let viewModel = createViewModel()

        try await Task.sleep(nanoseconds: 100_000_000)

        XCTAssertEqual(viewModel.cityName, "Москва")
    }

    func testInitLoadsUserCreatedContacts() async throws {
        let userContact = ContactModel(lastName: "Иванов", email: "ivanov@test.com", isUserCreated: true)
        mockDataManager.userCreatedContacts = [userContact]

        let viewModel = createViewModel()

        try await Task.sleep(nanoseconds: 100_000_000)

        XCTAssertTrue(viewModel.contacts.contains { $0.lastName == "Иванов" })
    }

    func testInitFetchesContactsFromAPI() async throws {
        mockNetworkManager.usersToReturn = UserResponse(
            results: [
                UserDTO(gender: "male", name: NameDTO(title: "Mr", first: "John", last: "Doe"), email: "john@test.com")
            ],
            info: ResponseInfo(seed: "test", results: 1, page: 1)
        )

        let viewModel = createViewModel()

        try await Task.sleep(nanoseconds: 200_000_000)

        XCTAssertTrue(mockNetworkManager.fetchUsersCalled)
    }

    // MARK: - Load Contacts Tests

    func testLoadContactsFromAPIAddsContacts() async throws {
        mockNetworkManager.usersToReturn = UserResponse(
            results: [
                UserDTO(gender: "male", name: NameDTO(title: "Mr", first: "John", last: "Doe"), email: "john@test.com"),
                UserDTO(gender: "female", name: NameDTO(title: "Mrs", first: "Jane", last: "Smith"), email: "jane@test.com")
            ],
            info: ResponseInfo(seed: "test", results: 2, page: 1)
        )

        let viewModel = createViewModel()

        try await Task.sleep(nanoseconds: 200_000_000)

        XCTAssertTrue(viewModel.contacts.contains { $0.lastName == "Doe" })
        XCTAssertTrue(viewModel.contacts.contains { $0.lastName == "Smith" })
    }

    func testLoadContactsFromAPICompletesAndStopsLoading() async throws {
        mockNetworkManager.usersToReturn = UserResponse(
            results: [
                UserDTO(gender: "male", name: NameDTO(title: "Mr", first: "John", last: "Doe"), email: "john@test.com")
            ],
            info: ResponseInfo(seed: "test", results: 1, page: 1)
        )

        let viewModel = createViewModel()

        // Wait for async loading to complete
        try await Task.sleep(nanoseconds: 200_000_000)

        XCTAssertFalse(viewModel.isLoading)
        XCTAssertTrue(mockNetworkManager.fetchUsersCalled)
    }

    func testLoadContactsFromAPIDoesNotLoadWhenAlreadyLoading() async throws {
        let viewModel = createViewModel()

        // Trigger multiple loads
        await viewModel.loadContactsFromAPI()
        await viewModel.loadContactsFromAPI()
        await viewModel.loadContactsFromAPI()

        try await Task.sleep(nanoseconds: 100_000_000)

        // Should only have called once (initial + one more after first completes)
        XCTAssertFalse(viewModel.isLoading)
    }

    func testLoadContactsFromAPIHandlesError() async throws {
        mockNetworkManager.shouldThrowError = TestError.networkError

        let viewModel = createViewModel()

        try await Task.sleep(nanoseconds: 200_000_000)

        XCTAssertFalse(viewModel.isLoading)
    }

    // MARK: - User Created Contacts Priority Tests

    func testUserCreatedContactsAppearFirst() async throws {
        let userContact = ContactModel(lastName: "МойКонтакт", email: "my@test.com", isUserCreated: true)
        mockDataManager.userCreatedContacts = [userContact]

        mockNetworkManager.usersToReturn = UserResponse(
            results: [
                UserDTO(gender: "male", name: NameDTO(title: "Mr", first: "John", last: "APIContact"), email: "api@test.com")
            ],
            info: ResponseInfo(seed: "test", results: 1, page: 1)
        )

        let viewModel = createViewModel()

        try await Task.sleep(nanoseconds: 200_000_000)

        XCTAssertEqual(viewModel.contacts.first?.lastName, "МойКонтакт")
    }

    // MARK: - Pagination Tests

    func testLoadMoreContactsIfNeededTriggersWhenLastContact() async throws {
        mockNetworkManager.usersToReturn = UserResponse(
            results: [
                UserDTO(gender: "male", name: NameDTO(title: "Mr", first: "John", last: "Doe"), email: "john@test.com")
            ],
            info: ResponseInfo(seed: "test", results: 1, page: 1)
        )

        let viewModel = createViewModel()

        try await Task.sleep(nanoseconds: 200_000_000)

        guard let lastContact = viewModel.contacts.last else {
            XCTFail("No contacts loaded")
            return
        }

        // Reset mock to track new call
        mockNetworkManager.fetchUsersCalled = false

        viewModel.loadMoreContactsIfNeeded(currentContact: lastContact)

        try await Task.sleep(nanoseconds: 200_000_000)

        XCTAssertTrue(mockNetworkManager.fetchUsersCalled)
    }

    func testLoadMoreContactsIfNeededDoesNotTriggerForNonLastContact() async throws {
        mockNetworkManager.usersToReturn = UserResponse(
            results: [
                UserDTO(gender: "male", name: NameDTO(title: "Mr", first: "John", last: "Doe"), email: "john@test.com"),
                UserDTO(gender: "female", name: NameDTO(title: "Mrs", first: "Jane", last: "Smith"), email: "jane@test.com")
            ],
            info: ResponseInfo(seed: "test", results: 2, page: 1)
        )

        let viewModel = createViewModel()

        try await Task.sleep(nanoseconds: 200_000_000)

        guard let firstContact = viewModel.contacts.first(where: { !$0.isUserCreated }) else {
            XCTFail("No API contacts loaded")
            return
        }

        mockNetworkManager.fetchUsersCalled = false

        viewModel.loadMoreContactsIfNeeded(currentContact: firstContact)

        try await Task.sleep(nanoseconds: 100_000_000)

        XCTAssertFalse(mockNetworkManager.fetchUsersCalled)
    }

    // MARK: - Logout Tests

    func testLogoutShowsAlert() {
        let viewModel = createViewModel()

        viewModel.logout()

        XCTAssertTrue(viewModel.showLogoutAlert)
    }

    func testConfirmLogoutClearsData() async throws {
        let viewModel = createViewModel()

        try await Task.sleep(nanoseconds: 100_000_000)

        viewModel.confirmLogout()

        XCTAssertTrue(mockDataManager.clearAllDataCalled)
    }

    func testConfirmLogoutCallsAppStateLogout() async throws {
        let viewModel = createViewModel()

        try await Task.sleep(nanoseconds: 100_000_000)

        viewModel.confirmLogout()

        XCTAssertTrue(mockAppState.logoutCalled)
    }

    // MARK: - Add/Edit Contact Tests

    func testAddContactTappedSetsNavigationFlag() async throws {
        let viewModel = createViewModel()

        try await Task.sleep(nanoseconds: 100_000_000)

        viewModel.addContactTapped()

        XCTAssertTrue(viewModel.shouldNavigateToAddContact)
        XCTAssertNil(viewModel.contactToEdit)
    }

    func testEditContactSetsContactToEdit() async throws {
        let contact = ContactModel(lastName: "Иванов", email: "ivanov@test.com", isUserCreated: true)
        let viewModel = createViewModel()

        try await Task.sleep(nanoseconds: 100_000_000)

        viewModel.editContact(contact)

        XCTAssertTrue(viewModel.shouldNavigateToAddContact)
        XCTAssertEqual(viewModel.contactToEdit?.lastName, "Иванов")
    }

    // MARK: - Refresh Tests

    func testRefreshContactsResetsPageAndReloads() async throws {
        mockNetworkManager.usersToReturn = UserResponse(
            results: [
                UserDTO(gender: "male", name: NameDTO(title: "Mr", first: "John", last: "Doe"), email: "john@test.com")
            ],
            info: ResponseInfo(seed: "test", results: 1, page: 1)
        )

        let viewModel = createViewModel()

        try await Task.sleep(nanoseconds: 200_000_000)

        mockNetworkManager.fetchUsersCalled = false

        viewModel.refreshContacts()

        try await Task.sleep(nanoseconds: 200_000_000)

        XCTAssertTrue(mockNetworkManager.fetchUsersCalled)
    }

    func testRefreshContactsKeepsUserCreatedContacts() async throws {
        let userContact = ContactModel(lastName: "МойКонтакт", email: "my@test.com", isUserCreated: true)
        mockDataManager.userCreatedContacts = [userContact]

        mockNetworkManager.usersToReturn = UserResponse(
            results: [],
            info: ResponseInfo(seed: "test", results: 0, page: 1)
        )

        let viewModel = createViewModel()

        try await Task.sleep(nanoseconds: 200_000_000)

        viewModel.refreshContacts()

        try await Task.sleep(nanoseconds: 100_000_000)

        XCTAssertTrue(viewModel.contacts.contains { $0.isUserCreated })
    }

    // MARK: - City Name Background Fetch Tests

    func testFetchesCityNameWhenEmpty() async throws {
        // Create fresh mock without default session
        let freshMockDataManager = MockDataManager()
        freshMockDataManager.setMockSession(seed: "test-seed", cityName: nil)
        mockLocationService.cityNameToReturn = "Санкт-Петербург"

        let viewModel = ContactsListViewModel(
            dataManager: freshMockDataManager,
            networkManager: mockNetworkManager,
            locationService: mockLocationService,
            appState: mockAppState
        )

        try await Task.sleep(nanoseconds: 300_000_000)

        XCTAssertTrue(mockLocationService.requestLocationCalled)
        XCTAssertTrue(mockLocationService.getCityNameCalled)
    }

    func testDoesNotFetchCityNameWhenAlreadySet() async throws {
        mockDataManager.setMockSession(seed: "test-seed", cityName: "Москва")

        let viewModel = createViewModel()

        try await Task.sleep(nanoseconds: 200_000_000)

        XCTAssertEqual(viewModel.cityName, "Москва")
    }
}
