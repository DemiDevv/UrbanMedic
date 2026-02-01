//
//  AddEditContactViewModel.swift
//  UrbanMedic
//
//  Created by Demain Petropavlov on 01.02.2026.
//

import Foundation
import Combine

final class AddEditContactViewModel: ObservableObject {

    @Published var lastName: String = ""
    @Published var email: String = ""

    let mode: AddEditContactView.Mode

    private let initialLastName: String
    private let initialEmail: String

    init(mode: AddEditContactView.Mode) {
        self.mode = mode

        if case .edit(let contact) = mode {
            self.lastName = contact.lastName
            self.email = contact.email
            self.initialLastName = contact.lastName
            self.initialEmail = contact.email
        } else {
            self.initialLastName = ""
            self.initialEmail = ""
        }
    }

    // MARK: - Validation

    var isValid: Bool {
        isLastNameValid && isEmailValid
    }

    var hasChanges: Bool {
        lastName != initialLastName || email != initialEmail
    }

    private var isLastNameValid: Bool {
        let trimmed = lastName.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty, trimmed.count <= 25 else { return false }

        let pattern = "^[а-яА-ЯёЁa-zA-Z-]+$"
        return trimmed.range(of: pattern, options: .regularExpression) != nil
    }

    private var isEmailValid: Bool {
        let trimmed = email.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return false }

        let pattern = "^[^\\s@]+@[^\\s@]+\\.[^\\s@]+$"
        return trimmed.range(of: pattern, options: .regularExpression) != nil
    }

    // MARK: - Actions

    func save() {
        // TODO: Implement saving logic
        print("Saving contact: \(lastName), \(email)")
    }
}
