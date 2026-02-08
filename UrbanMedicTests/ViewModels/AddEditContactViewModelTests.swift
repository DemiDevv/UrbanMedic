//
//  AddEditContactViewModelTests.swift
//  UrbanMedicTests
//

import XCTest
@testable import UrbanMedic

@MainActor
final class AddEditContactViewModelTests: XCTestCase {

    private var mockDataManager: MockDataManager!

    override func setUp() {
        super.setUp()
        mockDataManager = MockDataManager()
    }

    override func tearDown() {
        mockDataManager = nil
        super.tearDown()
    }

    // MARK: - Initialization Tests

    func testInitWithAddMode() {
        let viewModel = AddEditContactViewModel(mode: .add, dataManager: mockDataManager)

        XCTAssertEqual(viewModel.lastName, "")
        XCTAssertEqual(viewModel.email, "")
        XCTAssertFalse(viewModel.hasChanges)
    }

    func testInitWithEditMode() {
        let contact = ContactModel(lastName: "Иванов", email: "ivanov@test.com", isUserCreated: true)
        let viewModel = AddEditContactViewModel(mode: .edit(contact), dataManager: mockDataManager)

        XCTAssertEqual(viewModel.lastName, "Иванов")
        XCTAssertEqual(viewModel.email, "ivanov@test.com")
        XCTAssertFalse(viewModel.hasChanges)
    }

    // MARK: - Last Name Validation Tests

    func testLastNameValidWithCyrillic() {
        let viewModel = AddEditContactViewModel(mode: .add, dataManager: mockDataManager)
        viewModel.lastName = "Иванов"

        XCTAssertTrue(viewModel.isLastNameValid)
        XCTAssertFalse(viewModel.showLastNameError)
    }

    func testLastNameValidWithLatin() {
        let viewModel = AddEditContactViewModel(mode: .add, dataManager: mockDataManager)
        viewModel.lastName = "Johnson"

        XCTAssertTrue(viewModel.isLastNameValid)
        XCTAssertFalse(viewModel.showLastNameError)
    }

    func testLastNameValidWithHyphen() {
        let viewModel = AddEditContactViewModel(mode: .add, dataManager: mockDataManager)
        viewModel.lastName = "Петров-Водкин"

        XCTAssertTrue(viewModel.isLastNameValid)
    }

    func testLastNameInvalidWhenEmpty() {
        let viewModel = AddEditContactViewModel(mode: .add, dataManager: mockDataManager)
        viewModel.lastName = ""

        XCTAssertFalse(viewModel.isLastNameValid)
        XCTAssertFalse(viewModel.showLastNameError) // Empty doesn't show error
    }

    func testLastNameInvalidWhenOnlySpaces() {
        let viewModel = AddEditContactViewModel(mode: .add, dataManager: mockDataManager)
        viewModel.lastName = "   "

        XCTAssertFalse(viewModel.isLastNameValid)
    }

    func testLastNameInvalidWithNumbers() {
        let viewModel = AddEditContactViewModel(mode: .add, dataManager: mockDataManager)
        viewModel.lastName = "Иванов123"

        XCTAssertFalse(viewModel.isLastNameValid)
        XCTAssertTrue(viewModel.showLastNameError)
    }

    func testLastNameInvalidWithSpecialCharacters() {
        let viewModel = AddEditContactViewModel(mode: .add, dataManager: mockDataManager)
        viewModel.lastName = "Иванов@"

        XCTAssertFalse(viewModel.isLastNameValid)
        XCTAssertTrue(viewModel.showLastNameError)
    }

    func testLastNameInvalidWhenTooLong() {
        let viewModel = AddEditContactViewModel(mode: .add, dataManager: mockDataManager)
        viewModel.lastName = "АбвгдежзийклмнопрстуфхцчшщъЫ" // 28 chars

        XCTAssertFalse(viewModel.isLastNameValid)
        XCTAssertTrue(viewModel.showLastNameError)
    }

    func testLastNameValidAtMaxLength() {
        let viewModel = AddEditContactViewModel(mode: .add, dataManager: mockDataManager)
        viewModel.lastName = "Абвгдежзийклмнопрстуфхцчш" // 25 chars

        XCTAssertTrue(viewModel.isLastNameValid)
    }

    // MARK: - Email Validation Tests

    func testEmailValidSimple() {
        let viewModel = AddEditContactViewModel(mode: .add, dataManager: mockDataManager)
        viewModel.email = "test@example.com"

        XCTAssertTrue(viewModel.isEmailValid)
        XCTAssertFalse(viewModel.showEmailError)
    }

    func testEmailValidWithSubdomain() {
        let viewModel = AddEditContactViewModel(mode: .add, dataManager: mockDataManager)
        viewModel.email = "user@mail.example.com"

        XCTAssertTrue(viewModel.isEmailValid)
    }

    func testEmailValidWithPlus() {
        let viewModel = AddEditContactViewModel(mode: .add, dataManager: mockDataManager)
        viewModel.email = "user+tag@example.com"

        XCTAssertTrue(viewModel.isEmailValid)
    }

    func testEmailInvalidWhenEmpty() {
        let viewModel = AddEditContactViewModel(mode: .add, dataManager: mockDataManager)
        viewModel.email = ""

        XCTAssertFalse(viewModel.isEmailValid)
        XCTAssertFalse(viewModel.showEmailError) // Empty doesn't show error
    }

    func testEmailInvalidWithoutAt() {
        let viewModel = AddEditContactViewModel(mode: .add, dataManager: mockDataManager)
        viewModel.email = "testexample.com"

        XCTAssertFalse(viewModel.isEmailValid)
        XCTAssertTrue(viewModel.showEmailError)
    }

    func testEmailInvalidWithoutDomain() {
        let viewModel = AddEditContactViewModel(mode: .add, dataManager: mockDataManager)
        viewModel.email = "test@"

        XCTAssertFalse(viewModel.isEmailValid)
        XCTAssertTrue(viewModel.showEmailError)
    }

    func testEmailInvalidWithSpaces() {
        let viewModel = AddEditContactViewModel(mode: .add, dataManager: mockDataManager)
        viewModel.email = "test @example.com"

        XCTAssertFalse(viewModel.isEmailValid)
        XCTAssertTrue(viewModel.showEmailError)
    }

    // MARK: - Overall Validation Tests

    func testIsValidWhenBothFieldsValid() {
        let viewModel = AddEditContactViewModel(mode: .add, dataManager: mockDataManager)
        viewModel.lastName = "Иванов"
        viewModel.email = "ivanov@test.com"

        XCTAssertTrue(viewModel.isValid)
    }

    func testIsValidFalseWhenLastNameInvalid() {
        let viewModel = AddEditContactViewModel(mode: .add, dataManager: mockDataManager)
        viewModel.lastName = "123"
        viewModel.email = "test@test.com"

        XCTAssertFalse(viewModel.isValid)
    }

    func testIsValidFalseWhenEmailInvalid() {
        let viewModel = AddEditContactViewModel(mode: .add, dataManager: mockDataManager)
        viewModel.lastName = "Иванов"
        viewModel.email = "invalid"

        XCTAssertFalse(viewModel.isValid)
    }

    // MARK: - Has Changes Tests

    func testHasChangesWhenLastNameChanged() {
        let contact = ContactModel(lastName: "Иванов", email: "ivanov@test.com", isUserCreated: true)
        let viewModel = AddEditContactViewModel(mode: .edit(contact), dataManager: mockDataManager)

        viewModel.lastName = "Петров"

        XCTAssertTrue(viewModel.hasChanges)
    }

    func testHasChangesWhenEmailChanged() {
        let contact = ContactModel(lastName: "Иванов", email: "ivanov@test.com", isUserCreated: true)
        let viewModel = AddEditContactViewModel(mode: .edit(contact), dataManager: mockDataManager)

        viewModel.email = "petrov@test.com"

        XCTAssertTrue(viewModel.hasChanges)
    }

    func testHasChangesResetAfterRevertingToOriginal() {
        let contact = ContactModel(lastName: "Иванов", email: "ivanov@test.com", isUserCreated: true)
        let viewModel = AddEditContactViewModel(mode: .edit(contact), dataManager: mockDataManager)

        viewModel.lastName = "Петров"
        XCTAssertTrue(viewModel.hasChanges)

        viewModel.lastName = "Иванов"
        XCTAssertFalse(viewModel.hasChanges)
    }

    // MARK: - Save Tests

    func testSaveInAddMode() {
        mockDataManager.setMockSession(seed: "test-seed", cityName: "Москва")
        let viewModel = AddEditContactViewModel(mode: .add, dataManager: mockDataManager)

        viewModel.lastName = "Новый"
        viewModel.email = "new@test.com"
        viewModel.save()

        XCTAssertEqual(mockDataManager.savedContacts.count, 1)
        XCTAssertEqual(mockDataManager.savedContacts.first?.lastName, "Новый")
        XCTAssertEqual(mockDataManager.savedContacts.first?.email, "new@test.com")
        XCTAssertTrue(mockDataManager.savedContacts.first?.isUserCreated ?? false)
    }

    func testSaveInEditMode() {
        mockDataManager.setMockSession(seed: "test-seed", cityName: "Москва")
        let originalContact = ContactModel(lastName: "Иванов", email: "ivanov@test.com", isUserCreated: true)
        mockDataManager.savedContacts.append(originalContact)

        let viewModel = AddEditContactViewModel(mode: .edit(originalContact), dataManager: mockDataManager)
        viewModel.lastName = "Петров"
        viewModel.email = "petrov@test.com"
        viewModel.save()

        XCTAssertEqual(mockDataManager.savedContacts.first?.lastName, "Петров")
        XCTAssertEqual(mockDataManager.savedContacts.first?.email, "petrov@test.com")
    }

    func testSaveDoesNothingWhenInvalid() {
        mockDataManager.setMockSession(seed: "test-seed", cityName: "Москва")
        let viewModel = AddEditContactViewModel(mode: .add, dataManager: mockDataManager)

        viewModel.lastName = "123" // Invalid
        viewModel.email = "test@test.com"
        viewModel.save()

        XCTAssertTrue(mockDataManager.savedContacts.isEmpty)
    }

    func testSaveDoesNothingWithoutSession() {
        // Don't set mock session - by default there's no session
        let viewModel = AddEditContactViewModel(mode: .add, dataManager: mockDataManager)

        viewModel.lastName = "Иванов"
        viewModel.email = "test@test.com"
        viewModel.save()

        XCTAssertTrue(mockDataManager.savedContacts.isEmpty)
    }

    func testSaveTrimsWhitespace() {
        mockDataManager.setMockSession(seed: "test-seed", cityName: "Москва")
        let viewModel = AddEditContactViewModel(mode: .add, dataManager: mockDataManager)

        viewModel.lastName = "  Иванов  "
        viewModel.email = "  test@test.com  "
        viewModel.save()

        XCTAssertEqual(mockDataManager.savedContacts.first?.lastName, "Иванов")
        XCTAssertEqual(mockDataManager.savedContacts.first?.email, "test@test.com")
    }
}
