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

    static var signIn: String {
        AppState.shared.selectedLanguage == .ru ? "Войти" : "Sign in"
    }

    static var seed: String {
        AppState.shared.selectedLanguage == .ru ? "Укажите Сид" : "Enter Seed"
    }

    // MARK: - Contacts

    static var lastName: String {
        AppState.shared.selectedLanguage == .ru ? "Фамилия" : "Last name"
    }

    static var email: String {
        AppState.shared.selectedLanguage == .ru ? "Email" : "Email"
    }

    static var addContact: String {
        AppState.shared.selectedLanguage == .ru ? "Добавить контакт" : "Add contact"
    }

    // MARK: - Alerts

    static var areYouSure: String {
        AppState.shared.selectedLanguage == .ru
            ? "Вы уверены, что хотите выйти?"
            : "Are you sure you want to sign out?"
    }

    static var informationWillBeDeleted: String {
        AppState.shared.selectedLanguage == .ru
            ? "При выходе информация о сохраненных контактах будет удалена"
            : "When you exit, the information about your saved contacts will be deleted"
    }

    static var informationWillNotBeSaved: String {
        AppState.shared.selectedLanguage == .ru
            ? "При выходе введенная информация не сохранится"
            : "When you exit, the information you entered will not be saved"
    }

    static var cancel: String {
        AppState.shared.selectedLanguage == .ru ? "Отмена" : "Cancel"
    }

    static var exit: String {
        AppState.shared.selectedLanguage == .ru ? "Выйти" : "Exit"
    }

    // MARK: - Other

    static var unknown: String {
        AppState.shared.selectedLanguage == .ru ? "Неизвестно" : "Unknown"
    }

    // MARK: - Contact Edit

    static var newContact: String {
        AppState.shared.selectedLanguage == .ru ? "Новый контакт" : "New contact"
    }

    static var edit: String {
        AppState.shared.selectedLanguage == .ru ? "Редактировать" : "Edit"
    }

    static var save: String {
        AppState.shared.selectedLanguage == .ru ? "Сохранить" : "Save"
    }
}
