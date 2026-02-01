//
//  UserDTO.swift
//  UrbanMedic
//
//  Created by Demain Petropavlov on 02.02.2026.
//

import Foundation

// MARK: - Root Response

struct UserResponse: Codable {
    let results: [UserDTO]
    let info: ResponseInfo
}

// MARK: - User DTO

struct UserDTO: Codable {
    let gender: String
    let name: NameDTO
    let email: String
}

// MARK: - Name DTO

struct NameDTO: Codable {
    let title: String
    let first: String
    let last: String
}

// MARK: - Response Info

struct ResponseInfo: Codable {
    let seed: String
    let results: Int
    let page: Int
}

// MARK: - Mapping to Domain Model

extension UserDTO {
    func toDomainModel() -> ContactModel {
        ContactModel(
            id: UUID(),
            lastName: name.last,
            email: email,
            isUserCreated: false
        )
    }
}
