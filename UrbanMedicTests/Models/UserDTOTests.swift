//
//  UserDTOTests.swift
//  UrbanMedicTests
//

import XCTest
@testable import UrbanMedic

final class UserDTOTests: XCTestCase {

    // MARK: - UserDTO Tests

    func testUserDTODecoding() throws {
        let json = """
        {
            "gender": "male",
            "name": {
                "title": "Mr",
                "first": "John",
                "last": "Doe"
            },
            "email": "john.doe@example.com"
        }
        """.data(using: .utf8)!

        let userDTO = try JSONDecoder().decode(UserDTO.self, from: json)

        XCTAssertEqual(userDTO.gender, "male")
        XCTAssertEqual(userDTO.name.title, "Mr")
        XCTAssertEqual(userDTO.name.first, "John")
        XCTAssertEqual(userDTO.name.last, "Doe")
        XCTAssertEqual(userDTO.email, "john.doe@example.com")
    }

    func testUserDTOEncoding() throws {
        let userDTO = UserDTO(
            gender: "female",
            name: NameDTO(title: "Mrs", first: "Jane", last: "Smith"),
            email: "jane.smith@example.com"
        )

        let data = try JSONEncoder().encode(userDTO)
        let decoded = try JSONDecoder().decode(UserDTO.self, from: data)

        XCTAssertEqual(decoded.gender, userDTO.gender)
        XCTAssertEqual(decoded.email, userDTO.email)
        XCTAssertEqual(decoded.name.last, userDTO.name.last)
    }

    // MARK: - NameDTO Tests

    func testNameDTODecoding() throws {
        let json = """
        {
            "title": "Dr",
            "first": "Albert",
            "last": "Einstein"
        }
        """.data(using: .utf8)!

        let nameDTO = try JSONDecoder().decode(NameDTO.self, from: json)

        XCTAssertEqual(nameDTO.title, "Dr")
        XCTAssertEqual(nameDTO.first, "Albert")
        XCTAssertEqual(nameDTO.last, "Einstein")
    }

    // MARK: - UserResponse Tests

    func testUserResponseDecoding() throws {
        let json = """
        {
            "results": [
                {
                    "gender": "male",
                    "name": {"title": "Mr", "first": "John", "last": "Doe"},
                    "email": "john@test.com"
                },
                {
                    "gender": "female",
                    "name": {"title": "Mrs", "first": "Jane", "last": "Smith"},
                    "email": "jane@test.com"
                }
            ],
            "info": {
                "seed": "test-seed",
                "results": 2,
                "page": 1
            }
        }
        """.data(using: .utf8)!

        let response = try JSONDecoder().decode(UserResponse.self, from: json)

        XCTAssertEqual(response.results.count, 2)
        XCTAssertEqual(response.info.seed, "test-seed")
        XCTAssertEqual(response.info.results, 2)
        XCTAssertEqual(response.info.page, 1)
    }

    func testUserResponseWithEmptyResults() throws {
        let json = """
        {
            "results": [],
            "info": {
                "seed": "empty-seed",
                "results": 0,
                "page": 1
            }
        }
        """.data(using: .utf8)!

        let response = try JSONDecoder().decode(UserResponse.self, from: json)

        XCTAssertTrue(response.results.isEmpty)
        XCTAssertEqual(response.info.results, 0)
    }

    // MARK: - ResponseInfo Tests

    func testResponseInfoDecoding() throws {
        let json = """
        {
            "seed": "my-seed",
            "results": 20,
            "page": 5
        }
        """.data(using: .utf8)!

        let info = try JSONDecoder().decode(ResponseInfo.self, from: json)

        XCTAssertEqual(info.seed, "my-seed")
        XCTAssertEqual(info.results, 20)
        XCTAssertEqual(info.page, 5)
    }

    // MARK: - Domain Model Mapping Tests

    func testToDomainModel() {
        let userDTO = UserDTO(
            gender: "male",
            name: NameDTO(title: "Mr", first: "John", last: "Doe"),
            email: "john.doe@example.com"
        )

        let contact = userDTO.toDomainModel()

        XCTAssertEqual(contact.lastName, "Doe")
        XCTAssertEqual(contact.email, "john.doe@example.com")
        XCTAssertFalse(contact.isUserCreated)
        XCTAssertNotNil(contact.id)
    }

    func testToDomainModelGeneratesUniqueIds() {
        let userDTO = UserDTO(
            gender: "male",
            name: NameDTO(title: "Mr", first: "John", last: "Doe"),
            email: "john@example.com"
        )

        let contact1 = userDTO.toDomainModel()
        let contact2 = userDTO.toDomainModel()

        // Each call should generate a new UUID
        XCTAssertNotEqual(contact1.id, contact2.id)
    }

    func testToDomainModelPreservesLastNameExactly() {
        let userDTO = UserDTO(
            gender: "female",
            name: NameDTO(title: "Ms", first: "Maria", last: "García-López"),
            email: "maria@example.com"
        )

        let contact = userDTO.toDomainModel()

        XCTAssertEqual(contact.lastName, "García-López")
    }

    func testToDomainModelWithCyrillicName() {
        let userDTO = UserDTO(
            gender: "male",
            name: NameDTO(title: "Mr", first: "Иван", last: "Иванов"),
            email: "ivan@example.com"
        )

        let contact = userDTO.toDomainModel()

        XCTAssertEqual(contact.lastName, "Иванов")
    }

    func testToDomainModelSetsIsUserCreatedToFalse() {
        let userDTO = UserDTO(
            gender: "male",
            name: NameDTO(title: "Mr", first: "Test", last: "User"),
            email: "test@example.com"
        )

        let contact = userDTO.toDomainModel()

        XCTAssertFalse(contact.isUserCreated)
    }

    // MARK: - Batch Mapping Tests

    func testBatchMappingFromUserResponse() throws {
        let json = """
        {
            "results": [
                {
                    "gender": "male",
                    "name": {"title": "Mr", "first": "John", "last": "Doe"},
                    "email": "john@test.com"
                },
                {
                    "gender": "female",
                    "name": {"title": "Mrs", "first": "Jane", "last": "Smith"},
                    "email": "jane@test.com"
                },
                {
                    "gender": "male",
                    "name": {"title": "Dr", "first": "Alex", "last": "Johnson"},
                    "email": "alex@test.com"
                }
            ],
            "info": {"seed": "test", "results": 3, "page": 1}
        }
        """.data(using: .utf8)!

        let response = try JSONDecoder().decode(UserResponse.self, from: json)
        let contacts = response.results.map { $0.toDomainModel() }

        XCTAssertEqual(contacts.count, 3)
        XCTAssertEqual(contacts[0].lastName, "Doe")
        XCTAssertEqual(contacts[1].lastName, "Smith")
        XCTAssertEqual(contacts[2].lastName, "Johnson")

        // All should be marked as not user created
        XCTAssertTrue(contacts.allSatisfy { !$0.isUserCreated })

        // All should have unique IDs
        let uniqueIds = Set(contacts.map { $0.id })
        XCTAssertEqual(uniqueIds.count, 3)
    }

    // MARK: - Edge Cases

    func testUserDTOWithEmptyName() throws {
        let json = """
        {
            "gender": "other",
            "name": {"title": "", "first": "", "last": ""},
            "email": "empty@test.com"
        }
        """.data(using: .utf8)!

        let userDTO = try JSONDecoder().decode(UserDTO.self, from: json)
        let contact = userDTO.toDomainModel()

        XCTAssertEqual(contact.lastName, "")
        XCTAssertEqual(contact.email, "empty@test.com")
    }

    func testUserDTOWithSpecialCharactersInEmail() throws {
        let json = """
        {
            "gender": "male",
            "name": {"title": "Mr", "first": "Test", "last": "User"},
            "email": "test+special.chars_123@sub.example.com"
        }
        """.data(using: .utf8)!

        let userDTO = try JSONDecoder().decode(UserDTO.self, from: json)

        XCTAssertEqual(userDTO.email, "test+special.chars_123@sub.example.com")
    }

    func testUserDTOWithUnicodeInName() throws {
        let json = """
        {
            "gender": "female",
            "name": {"title": "Frau", "first": "Müller", "last": "Schrödinger"},
            "email": "test@example.com"
        }
        """.data(using: .utf8)!

        let userDTO = try JSONDecoder().decode(UserDTO.self, from: json)

        XCTAssertEqual(userDTO.name.first, "Müller")
        XCTAssertEqual(userDTO.name.last, "Schrödinger")
    }
}
