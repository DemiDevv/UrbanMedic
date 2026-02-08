//
//  AuthViewModelTests.swift
//  UrbanMedicTests
//

import XCTest
@testable import UrbanMedic

@MainActor
final class AuthViewModelTests: XCTestCase {

    private var mockDataManager: MockDataManager!
    private var mockLocationService: MockLocationService!
    private var mockNotificationService: MockNotificationService!
    private var mockVibrationService: MockVibrationService!
    private var mockAppState: MockAppState!

    override func setUp() {
        super.setUp()
        mockDataManager = MockDataManager()
        mockLocationService = MockLocationService()
        mockNotificationService = MockNotificationService()
        mockVibrationService = MockVibrationService()
        mockAppState = MockAppState()
    }

    override func tearDown() {
        mockDataManager = nil
        mockLocationService = nil
        mockNotificationService = nil
        mockVibrationService = nil
        mockAppState = nil
        super.tearDown()
    }

    private func createViewModel() -> AuthViewModel {
        return AuthViewModel(
            dataManager: mockDataManager,
            locationService: mockLocationService,
            notificationService: mockNotificationService,
            vibrationService: mockVibrationService,
            appState: mockAppState
        )
    }

    // MARK: - Initialization Tests

    func testInitialState() {
        let viewModel = createViewModel()

        XCTAssertEqual(viewModel.seed, "")
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNil(viewModel.errorMessage)
        XCTAssertFalse(viewModel.shouldNavigateToContacts)
    }

    func testInitWithExistingSession() {
        mockDataManager.setMockSession(seed: "existing-seed", cityName: nil)

        let viewModel = createViewModel()

        XCTAssertEqual(viewModel.seed, "existing-seed")
        XCTAssertTrue(viewModel.shouldNavigateToContacts)
    }

    // MARK: - Confirm Button State Tests

    func testIsConfirmEnabledWhenSeedNotEmpty() {
        let viewModel = createViewModel()
        viewModel.seed = "test-seed"

        XCTAssertTrue(viewModel.isConfirmEnabled)
    }

    func testIsConfirmDisabledWhenSeedEmpty() {
        let viewModel = createViewModel()
        viewModel.seed = ""

        XCTAssertFalse(viewModel.isConfirmEnabled)
    }

    func testIsConfirmDisabledWhenSeedOnlyWhitespace() {
        let viewModel = createViewModel()
        viewModel.seed = "   "

        XCTAssertFalse(viewModel.isConfirmEnabled)
    }

    func testIsConfirmDisabledWhenLoading() {
        let viewModel = createViewModel()
        viewModel.seed = "test-seed"

        // Simulate loading state
        viewModel.confirmTapped()

        XCTAssertFalse(viewModel.isConfirmEnabled)
    }

    // MARK: - Confirm Tapped Tests

    func testConfirmTappedSetsLoading() {
        let viewModel = createViewModel()
        viewModel.seed = "test-seed"

        viewModel.confirmTapped()

        XCTAssertTrue(viewModel.isLoading)
    }

    func testConfirmTappedClearsErrorMessage() {
        let viewModel = createViewModel()
        viewModel.seed = "test-seed"
        viewModel.confirmTapped()

        XCTAssertNil(viewModel.errorMessage)
    }

    func testConfirmTappedDoesNothingWhenDisabled() {
        let viewModel = createViewModel()
        viewModel.seed = "" // Empty seed

        viewModel.confirmTapped()

        XCTAssertFalse(viewModel.isLoading)
    }

    // MARK: - Auth Flow Tests

    func testSuccessfulAuthFlowSavesSession() async throws {
        let viewModel = createViewModel()
        viewModel.seed = "test-seed"

        viewModel.confirmTapped()

        // Wait for async operations
        try await Task.sleep(nanoseconds: 100_000_000)

        XCTAssertTrue(mockDataManager.saveSessionCalled)
        XCTAssertEqual(mockDataManager.lastSavedSeed, "test-seed")
    }

    func testSuccessfulAuthFlowTriggersVibration() async throws {
        let viewModel = createViewModel()
        viewModel.seed = "test-seed"

        viewModel.confirmTapped()

        try await Task.sleep(nanoseconds: 100_000_000)

        XCTAssertTrue(mockVibrationService.triggerVibrationCalled)
    }

    func testSuccessfulAuthFlowRequestsNotificationPermission() async throws {
        let viewModel = createViewModel()
        viewModel.seed = "test-seed"

        viewModel.confirmTapped()

        try await Task.sleep(nanoseconds: 100_000_000)

        XCTAssertTrue(mockNotificationService.requestPermissionCalled)
    }

    func testSuccessfulAuthFlowSendsNotificationWhenGranted() async throws {
        mockNotificationService.permissionGranted = true
        let viewModel = createViewModel()
        viewModel.seed = "test-seed"

        viewModel.confirmTapped()

        try await Task.sleep(nanoseconds: 100_000_000)

        XCTAssertTrue(mockNotificationService.sendNotificationCalled)
    }

    func testSuccessfulAuthFlowDoesNotSendNotificationWhenDenied() async throws {
        mockNotificationService.permissionGranted = false
        let viewModel = createViewModel()
        viewModel.seed = "test-seed"

        viewModel.confirmTapped()

        try await Task.sleep(nanoseconds: 100_000_000)

        XCTAssertFalse(mockNotificationService.sendNotificationCalled)
    }

    func testSuccessfulAuthFlowCallsAppStateLogin() async throws {
        let viewModel = createViewModel()
        viewModel.seed = "test-seed"

        viewModel.confirmTapped()

        try await Task.sleep(nanoseconds: 100_000_000)

        XCTAssertTrue(mockAppState.loginCalled)
    }

    func testSuccessfulAuthFlowSetsNavigateToContacts() async throws {
        let viewModel = createViewModel()
        viewModel.seed = "test-seed"

        viewModel.confirmTapped()

        try await Task.sleep(nanoseconds: 100_000_000)

        XCTAssertTrue(viewModel.shouldNavigateToContacts)
    }

    func testSuccessfulAuthFlowStopsLoading() async throws {
        let viewModel = createViewModel()
        viewModel.seed = "test-seed"

        viewModel.confirmTapped()

        try await Task.sleep(nanoseconds: 100_000_000)

        XCTAssertFalse(viewModel.isLoading)
    }

    // MARK: - Location Flow Tests

    func testAuthFlowRequestsLocation() async throws {
        let viewModel = createViewModel()
        viewModel.seed = "test-seed"

        viewModel.confirmTapped()

        try await Task.sleep(nanoseconds: 100_000_000)

        XCTAssertTrue(mockLocationService.requestLocationCalled)
    }

    func testAuthFlowGetsCityName() async throws {
        let viewModel = createViewModel()
        viewModel.seed = "test-seed"

        viewModel.confirmTapped()

        try await Task.sleep(nanoseconds: 100_000_000)

        XCTAssertTrue(mockLocationService.getCityNameCalled)
    }

    func testAuthFlowSavesCityName() async throws {
        mockLocationService.cityNameToReturn = "Москва"
        let viewModel = createViewModel()
        viewModel.seed = "test-seed"

        viewModel.confirmTapped()

        try await Task.sleep(nanoseconds: 100_000_000)

        XCTAssertEqual(mockDataManager.lastSavedCityName, "Москва")
    }

    func testAuthFlowContinuesWhenLocationFails() async throws {
        mockLocationService.shouldThrowError = TestError.locationError
        let viewModel = createViewModel()
        viewModel.seed = "test-seed"

        viewModel.confirmTapped()

        try await Task.sleep(nanoseconds: 100_000_000)

        // Auth should still complete
        XCTAssertTrue(mockDataManager.saveSessionCalled)
        XCTAssertNil(mockDataManager.lastSavedCityName)
        XCTAssertTrue(viewModel.shouldNavigateToContacts)
    }

    // MARK: - Seed Trimming Tests

    func testSeedIsTrimmedBeforeSaving() async throws {
        let viewModel = createViewModel()
        viewModel.seed = "  test-seed  "

        viewModel.confirmTapped()

        try await Task.sleep(nanoseconds: 100_000_000)

        XCTAssertEqual(mockDataManager.lastSavedSeed, "test-seed")
    }
}
