//
//  Constants.swift
//  UrbanMedic
//
//  Created by Demain Petropavlov on 01.02.2026.
//

import Foundation

enum Constants {

    enum Language {
        static let russian = "Русский"
        static let english = "English"
        static let ru = "ru"
        static let en = "en"
    }

    enum Auth {
        static let signIn = "Войти"
        static let seedTitle = "Укажите Seed"
        static let seedPlaceholder = "Введите Seed"
        static let seedLabel = "Seed"
        static let confirmButton = "Подтвердить"
    }

    enum Contacts {
        static let addContactButton = "Добавить контакт"
        static let numberColumn = "№"
        static let lastNameColumn = "Фамилия"
        static let emailColumn = "Почта"
    }

    enum Images {
        static let logo = "urban_medic_logo"
        static let doctorIllustration = "doctor_image"
        static let editIcon = "icon_edit"
        static let logoutIcon = "logout_Icon"
        static let xmarkIcon = "xmark_icon"
    }

    enum ContactEdit {
        static let newContactTitle = "Новый контакт"
        static let editContactTitle = "Редактировать"
        static let lastNamePlaceholder = "Фамилия*"
        static let emailPlaceholder = "Email*"
        static let addButton = "Добавить контакт"
        static let saveButton = "Сохранить"
        static let closeAlertTitle = "Вы уверены, что хотите выйти?"
        static let closeAlertMessage = "При выходе введенная информация не сохранится"
        static let closeAlertConfirm = "Выйти"
        static let closeAlertCancel = "Отмена"
    }
}
