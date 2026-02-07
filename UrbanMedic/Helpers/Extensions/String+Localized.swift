//
//  String+Localized.swift
//  UrbanMedic
//

import Foundation

extension String {
    var localized: String {
        guard let bundle = Bundle.forCurrentLanguage else {
            return self
        }
        return NSLocalizedString(self, bundle: bundle, comment: "")
    }
}

extension Bundle {
    private static let languageKey = "selectedLanguage"

    static var forCurrentLanguage: Bundle? {
        let languageCode = UserDefaults.standard.string(forKey: languageKey) ?? Language.ru.rawValue
        guard let path = Bundle.main.path(forResource: languageCode, ofType: "lproj"),
              let bundle = Bundle(path: path) else {
            return nil
        }
        return bundle
    }
}
