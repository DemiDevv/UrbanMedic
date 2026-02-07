//
//  LocalizedStrings.swift
//  UrbanMedic
//
//  Created by Demain Petropavlov on 03.02.2026.
//

import Foundation

enum Language: String {
    case ru
    case en
}

enum LocalizedStrings {

    // MARK: - Auth

    static var signIn: String { "sign_in".localized }
    static var seed: String { "seed".localized }
    static var enterSeed: String { "enter_seed".localized }
    static var seedLabel: String { "seed_label".localized }

    // MARK: - Contacts

    static var lastName: String { "last_name".localized }
    static var email: String { "email".localized }
    static var addContact: String { "add_contact".localized }
    static var newContact: String { "new_contact".localized }
    static var edit: String { "edit".localized }
    static var save: String { "save".localized }

    // MARK: - Alerts

    static var areYouSure: String { "are_you_sure".localized }
    static var informationWillBeDeleted: String { "information_will_be_deleted".localized }
    static var informationWillNotBeSaved: String { "information_will_not_be_saved".localized }
    static var cancel: String { "cancel".localized }
    static var exit: String { "exit".localized }

    // MARK: - Errors

    static var timeoutError: String { "timeout_error".localized }
    static var locationPermissionDenied: String { "location_permission_denied".localized }
    static var locationUnknownError: String { "location_unknown_error".localized }

    // MARK: - Notifications

    static var authSuccessNotification: String { "auth_success_notification".localized }

    // MARK: - Other

    static var unknown: String { "unknown".localized }
}
