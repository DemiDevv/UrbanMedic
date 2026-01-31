//
//  LanguageSegmentedControl.swift
//  UrbanMedic
//
//  Created by Demain Petropavlov on 01.02.2026.
//

import SwiftUI

struct LanguageSegmentedControl: View {

    @Binding var selectedLanguage: AuthViewModel.Language
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

    private func titleFor(_ language: AuthViewModel.Language) -> String {
        switch style {
        case .full:
            return language == .ru ? Constants.Language.russian : Constants.Language.english
        case .short:
            return language == .ru ? Constants.Language.ru : Constants.Language.en
        }
    }

    private func languageButton(title: String, language: AuthViewModel.Language) -> some View {
        Button {
            withAnimation(.easeInOut(duration: 0.2)) {
                selectedLanguage = language
            }
        } label: {
            Text(title)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(selectedLanguage == language ? .black : Color(UIColor.systemGray))
                .frame(maxWidth: .infinity)
                .frame(height: 40)
                .background(
                    selectedLanguage == language
                    ? Color.white
                    : Color.clear
                )
                .cornerRadius(8)
                .padding(3)
        }
    }
}

#Preview("Full Style") {
    PreviewWrapper(style: .full)
}

#Preview("Short Style") {
    PreviewWrapper(style: .short)
}

private struct PreviewWrapper: View {
    @State private var selectedLanguage: AuthViewModel.Language = .ru
    let style: LanguageSegmentedControl.Style

    var body: some View {
        LanguageSegmentedControl(selectedLanguage: $selectedLanguage, style: style)
            .padding()
    }
}
