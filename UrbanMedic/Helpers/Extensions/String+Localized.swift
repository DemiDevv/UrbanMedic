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
    static var forCurrentLanguage: Bundle? {
        let language = AppState.shared.selectedLanguage.rawValue
        guard let path = Bundle.main.path(forResource: language, ofType: "lproj"),
              let bundle = Bundle(path: path) else {
            return nil
        }
        return bundle
    }
}
