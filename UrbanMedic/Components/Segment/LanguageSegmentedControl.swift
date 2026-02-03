//
//  LanguageSegmentedControl.swift
//  UrbanMedic
//
//  Created by Demain Petropavlov on 01.02.2026.
//

import SwiftUI

struct LanguageSegmentedControl: View {

    @ObservedObject private var appState = AppState.shared
    var style: Style = .full

    enum Style {
        case full    // "Русский" / "English"
        case short   // "ru" / "en"
    }

    var body: some View {
        HStack(spacing: 0) {
            languageButton(title: titleFor(.ru), language: .ru)
            languageButton(title: titleFor(.en), language: .en)
        }
        .background(Color(UIColor.systemGray6))
        .cornerRadius(10)
    }

    private func titleFor(_ language: Language) -> String {
        switch style {
        case .full:
            return language == .ru ? Constants.Language.russian : Constants.Language.english
        case .short:
            return language == .ru ? Constants.Language.ru : Constants.Language.en
        }
    }

    private func languageButton(title: String, language: Language) -> some View {
        Button {
            withAnimation(.easeInOut(duration: 0.2)) {
                appState.selectedLanguage = language
            }
        } label: {
            Text(title)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(appState.selectedLanguage == language ? .black : Color(UIColor.systemGray))
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(
                    appState.selectedLanguage == language
                    ? Color.white
                    : Color.clear
                )
                .cornerRadius(8)
                .padding(3)
        }
    }
}

#Preview("Full Style") {
    LanguageSegmentedControl(style: .full)
        .frame(height: 40)
        .padding()
}

#Preview("Short Style") {
    LanguageSegmentedControl(style: .short)
        .frame(width: 69, height: 26)
        .padding()
}
