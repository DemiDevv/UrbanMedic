//
//  AuthViewModel.swift
//  UrbanMedic
//
//  Created by Demain Petropavlov on 01.02.2026.
//

import Foundation
import Combine

final class AuthViewModel: ObservableObject {

    @Published var seed: String = ""
    @Published var selectedLanguage: Language = .ru

    enum Language {
        case ru
        case en
    }

    var isConfirmEnabled: Bool {
        !seed.trimmingCharacters(in: .whitespaces).isEmpty
    }

    func confirmTapped() {
        // TODO: обработка Seed
        print("Seed:", seed)
    }

    func selectLanguage(_ language: Language) {
        selectedLanguage = language
        // TODO: применить локализацию
    }
}
