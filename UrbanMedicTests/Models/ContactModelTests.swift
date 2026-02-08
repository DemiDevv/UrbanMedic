//
//  ContactModelTests.swift
//  UrbanMedicTests
//

import XCTest
@testable import UrbanMedic

final class ContactModelTests: XCTestCase {

    // MARK: - Initialization Tests

    func testInitWithAllParameters() {
        let id = UUID()
        let contact = ContactModel(
            id: id,
            lastName: "Иванов",
            email: "ivanov@test.com",
            isUserCreated: true
        )

        XCTAssertEqual(contact.id, id)
        XCTAssertEqual(contact.lastName, "Иванов")
        XCTAssertEqual(contact.email, "ivanov@test.com")
        XCTAssertTrue(contact.isUserCreated)
    }

    func testInitWithDefaultId() {
        let contact = ContactModel(
            lastName: "Петров",
            email: "petrov@test.com",
            isUserCreated: false
        )

        XCTAssertNotNil(contact.id)
        XCTAssertEqual(contact.lastName, "Петров")
        XCTAssertEqual(contact.email, "petrov@test.com")
        XCTAssertFalse(contact.isUserCreated)
    }

    func testInitWithDefaultIsUserCreated() {
        let contact = ContactModel(
            lastName: "Сидоров",
            email: "sidorov@test.com"
        )

        XCTAssertFalse(contact.isUserCreated)
    }

    // MARK: - Identifiable Conformance Tests

    func testIdentifiableConformance() {
        let contact1 = ContactModel(lastName: "Test", email: "test@test.com")
        let contact2 = ContactModel(lastName: "Test", email: "test@test.com")

        // Different instances should have different IDs
        XCTAssertNotEqual(contact1.id, contact2.id)
    }

    func testIdentifiableWithSameId() {
        let id = UUID()
        let contact1 = ContactModel(id: id, lastName: "Test1", email: "test1@test.com")
        let contact2 = ContactModel(id: id, lastName: "Test2", email: "test2@test.com")

        XCTAssertEqual(contact1.id, contact2.id)
    }

    // MARK: - Hashable Conformance Tests

    func testHashableConformance() {
        let id = UUID()
        let contact1 = ContactModel(id: id, lastName: "Test", email: "test@test.com")
        let contact2 = ContactModel(id: id, lastName: "Test", email: "test@test.com")

        XCTAssertEqual(contact1.hashValue, contact2.hashValue)
    }

    func testHashableInSet() {
        let contact1 = ContactModel(lastName: "Иванов", email: "ivanov@test.com")
        let contact2 = ContactModel(lastName: "Петров", email: "petrov@test.com")

        var contactSet: Set<ContactModel> = []
        contactSet.insert(contact1)
        contactSet.insert(contact2)

        XCTAssertEqual(contactSet.count, 2)
    }

    func testHashableInSetWithSameId() {
        let id = UUID()
        let contact1 = ContactModel(id: id, lastName: "Иванов", email: "ivanov@test.com")
        let contact2 = ContactModel(id: id, lastName: "Петров", email: "petrov@test.com")

        var contactSet: Set<ContactModel> = []
        contactSet.insert(contact1)
        contactSet.insert(contact2)

        // Same ID should be treated as same element
        XCTAssertEqual(contactSet.count, 1)
    }

    // MARK: - Equatable Conformance Tests

    func testEquatableWithSameValues() {
        let id = UUID()
        let contact1 = ContactModel(id: id, lastName: "Test", email: "test@test.com", isUserCreated: true)
        let contact2 = ContactModel(id: id, lastName: "Test", email: "test@test.com", isUserCreated: true)

        XCTAssertEqual(contact1, contact2)
    }

    func testEquatableWithDifferentId() {
        let contact1 = ContactModel(lastName: "Test", email: "test@test.com")
        let contact2 = ContactModel(lastName: "Test", email: "test@test.com")

        XCTAssertNotEqual(contact1, contact2)
    }

    func testEquatableWithDifferentLastName() {
        let id = UUID()
        let contact1 = ContactModel(id: id, lastName: "Иванов", email: "test@test.com")
        let contact2 = ContactModel(id: id, lastName: "Петров", email: "test@test.com")

        XCTAssertNotEqual(contact1, contact2)
    }

    func testEquatableWithDifferentEmail() {
        let id = UUID()
        let contact1 = ContactModel(id: id, lastName: "Test", email: "test1@test.com")
        let contact2 = ContactModel(id: id, lastName: "Test", email: "test2@test.com")

        XCTAssertNotEqual(contact1, contact2)
    }

    func testEquatableWithDifferentIsUserCreated() {
        let id = UUID()
        let contact1 = ContactModel(id: id, lastName: "Test", email: "test@test.com", isUserCreated: true)
        let contact2 = ContactModel(id: id, lastName: "Test", email: "test@test.com", isUserCreated: false)

        XCTAssertNotEqual(contact1, contact2)
    }

    // MARK: - Edge Cases

    func testContactWithEmptyLastName() {
        let contact = ContactModel(lastName: "", email: "test@test.com")

        XCTAssertEqual(contact.lastName, "")
    }

    func testContactWithEmptyEmail() {
        let contact = ContactModel(lastName: "Test", email: "")

        XCTAssertEqual(contact.email, "")
    }

    func testContactWithUnicodeCharacters() {
        let contact = ContactModel(
            lastName: "Müller-Лüдтке",
            email: "test@пример.рф"
        )

        XCTAssertEqual(contact.lastName, "Müller-Лüдтке")
        XCTAssertEqual(contact.email, "test@пример.рф")
    }

    func testContactWithLongValues() {
        let longLastName = String(repeating: "А", count: 1000)
        let longEmail = String(repeating: "a", count: 500) + "@" + String(repeating: "b", count: 500) + ".com"

        let contact = ContactModel(lastName: longLastName, email: longEmail)

        XCTAssertEqual(contact.lastName.count, 1000)
        XCTAssertTrue(contact.email.contains("@"))
    }

    // MARK: - Collection Operations

    func testFilteringByIsUserCreated() {
        let contacts = [
            ContactModel(lastName: "User1", email: "user1@test.com", isUserCreated: true),
            ContactModel(lastName: "API1", email: "api1@test.com", isUserCreated: false),
            ContactModel(lastName: "User2", email: "user2@test.com", isUserCreated: true),
            ContactModel(lastName: "API2", email: "api2@test.com", isUserCreated: false)
        ]

        let userCreated = contacts.filter { $0.isUserCreated }
        let apiContacts = contacts.filter { !$0.isUserCreated }

        XCTAssertEqual(userCreated.count, 2)
        XCTAssertEqual(apiContacts.count, 2)
    }

    func testSortingByLastName() {
        let contacts = [
            ContactModel(lastName: "Яковлев", email: "test@test.com"),
            ContactModel(lastName: "Алексеев", email: "test@test.com"),
            ContactModel(lastName: "Михайлов", email: "test@test.com")
        ]

        let sorted = contacts.sorted { $0.lastName < $1.lastName }

        XCTAssertEqual(sorted[0].lastName, "Алексеев")
        XCTAssertEqual(sorted[1].lastName, "Михайлов")
        XCTAssertEqual(sorted[2].lastName, "Яковлев")
    }

    func testFindingById() {
        let targetId = UUID()
        let contacts = [
            ContactModel(lastName: "First", email: "first@test.com"),
            ContactModel(id: targetId, lastName: "Target", email: "target@test.com"),
            ContactModel(lastName: "Last", email: "last@test.com")
        ]

        let found = contacts.first { $0.id == targetId }

        XCTAssertNotNil(found)
        XCTAssertEqual(found?.lastName, "Target")
    }
}
