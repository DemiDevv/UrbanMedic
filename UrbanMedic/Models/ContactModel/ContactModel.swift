//
//  ContactModel.swift
//  UrbanMedic
//
//  Created by Demain Petropavlov on 01.02.2026.
//

import Foundation

struct ContactModel: Identifiable, Hashable {
    let id: UUID
    let lastName: String
    let email: String
    let isUserCreated: Bool

    init(id: UUID = UUID(), lastName: String, email: String, isUserCreated: Bool = false) {
        self.id = id
        self.lastName = lastName
        self.email = email
        self.isUserCreated = isUserCreated
    }
}
