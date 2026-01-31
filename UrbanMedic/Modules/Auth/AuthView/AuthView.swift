//
//  AuthView.swift
//  UrbanMedic
//
//  Created by Demain Petropavlov on 01.02.2026.
//

import SwiftUI

struct AuthView: View {

    @StateObject private var viewModel = AuthViewModel()

    var body: some View {
        VStack(spacing: 0) {

            Spacer().frame(height: 24)

            // Logo
            Image("urban_medic_logo")
                .resizable()
                .scaledToFit()
                .frame(height: 32)

            Spacer().frame(height: 32)

            // Illustration
            Image("doctor_image")
                .resizable()
                .scaledToFit()
                .frame(height: 220)

            Spacer().frame(height: 32)

            // Title
            Text("Укажите Seed")
                .font(.system(size: 24, weight: .semibold))

            Spacer().frame(height: 24)

            // Input
            VStack(alignment: .leading, spacing: 8) {
                Text("Seed")
                    .font(.system(size: 14))
                    .foregroundColor(.gray)

                TextField("Введите Seed", text: $viewModel.seed)
                    .font(.system(size: 16))
                    .padding(.vertical, 8)
                    .autocapitalization(.none)
                    .autocorrectionDisabled()
                    .overlay(
                        Rectangle()
                            .frame(height: 1)
                            .foregroundColor(Color.gray.opacity(0.3)),
                        alignment: .bottom
                    )
            }
            .padding(.horizontal, 24)

            Spacer().frame(height: 32)

            // Language switch
            HStack(spacing: 12) {
                languageButton(title: "Русский", lang: .ru)
                languageButton(title: "English", lang: .en)
            }
            .padding(.horizontal, 24)

            Spacer()

            // Confirm button
            PrimaryButton(
                title: "Подтвердить",
                isEnabled: viewModel.isConfirmEnabled
            ) {
                viewModel.confirmTapped()
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 24)
        }
    }

    // MARK: - Language Button

    private func languageButton(title: String, lang: AuthViewModel.Language) -> some View {
        Button {
            viewModel.selectLanguage(lang)
        } label: {
            Text(title)
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(viewModel.selectedLanguage == lang ? .black : .gray)
                .frame(maxWidth: .infinity)
                .frame(height: 44)
                .background(
                    viewModel.selectedLanguage == lang
                    ? Color.white
                    : Color.clear
                )
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.gray.opacity(0.2))
                )
        }
    }
}

#Preview {
    AuthView()
}
