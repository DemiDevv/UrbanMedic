//
//  AddEditContactViewModel.swift
//  UrbanMedic
//
//  Created by Demain Petropavlov on 01.02.2026.
//

import Foundation
import Combine

@MainActor
final class AddEditContactViewModel: ObservableObject {

    @Published var lastName: String = ""
    @Published var email: String = ""

    let mode: AddEditContactView.Mode

    private let initialLastName: String
    private let initialEmail: String
    private var editingContact: ContactModel?
    private let dataManager: DataManaging

    init(mode: AddEditContactView.Mode, dataManager: DataManaging) {
        self.mode = mode
        self.dataManager = dataManager

        if case .edit(let contact) = mode {
            self.lastName = contact.lastName
            self.email = contact.email
            self.initialLastName = contact.lastName
            self.initialEmail = contact.email
            self.editingContact = contact
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

    var isLastNameValid: Bool {
        let trimmed = lastName.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty, trimmed.count <= 25 else { return false }

        let pattern = "^[а-яА-ЯёЁa-zA-Z-]+$"
        return trimmed.range(of: pattern, options: .regularExpression) != nil
    }

    var isEmailValid: Bool {
        let trimmed = email.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return false }

        let pattern = "^[^\\s@]+@[^\\s@]+\\.[^\\s@]+$"
        return trimmed.range(of: pattern, options: .regularExpression) != nil
    }

    var showLastNameError: Bool {
        !lastName.isEmpty && !isLastNameValid
    }

    var showEmailError: Bool {
        !email.isEmpty && !isEmailValid
    }

    // MARK: - Save

    func save() {
        guard isValid else { return }
        guard let session = dataManager.getCurrentSession() else {
            print("No active session")
            return
        }

        let seed = session.seed ?? ""

        switch mode {
        case .add:
            let newContact = ContactModel(
                id: UUID(),
                lastName: lastName.trimmingCharacters(in: .whitespaces),
                email: email.trimmingCharacters(in: .whitespaces),
                isUserCreated: true
            )
            dataManager.saveContact(newContact, seed: seed)

        case .edit:
            guard let contact = editingContact else { return }

            let updatedContact = ContactModel(
                id: contact.id,
                lastName: lastName.trimmingCharacters(in: .whitespaces),
                email: email.trimmingCharacters(in: .whitespaces),
                isUserCreated: contact.isUserCreated
            )
            dataManager.updateContact(updatedContact, seed: seed)
        }
    }
}
