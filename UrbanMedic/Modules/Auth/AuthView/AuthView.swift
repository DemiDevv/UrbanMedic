//
//  AuthView.swift
//  UrbanMedic
//
//  Created by Demain Petropavlov on 01.02.2026.
//

import SwiftUI

struct AuthView: View {

    @StateObject private var viewModel = AuthViewModel()
    @ObservedObject private var appState = AppState.shared

    var body: some View {
        VStack(spacing: 0) {

            // Logo
            Image(Constants.Images.logo)
                .resizable()
                .scaledToFit()
                .frame(height: Layout.logoHeight)

            Spacer().frame(height: Layout.logoBottomSpacing)

            // Illustration
            Image(Constants.Images.doctorIllustration)
                .resizable()
                .scaledToFit()

            Spacer().frame(height: Layout.illustrationBottomSpacing)

            // Title
            Text(LocalizedStrings.seed)
                .font(.system(size: Layout.titleFontSize, weight: .regular))

            Spacer().frame(height: Layout.titleBottomSpacing)

            // Input
            VStack(alignment: .leading, spacing: 0) {
                Text("Seed")
                    .font(.system(size: Layout.labelFontSize))
                    .foregroundColor(.labelSecondary)

                TextField(LocalizedStrings.seed, text: $viewModel.seed)
                    .font(.system(size: Layout.textFieldFontSize))
                    .foregroundColor(.placeholderText)
                    .padding(.vertical, Layout.textFieldVerticalPadding)
                    .autocapitalization(.none)
                    .autocorrectionDisabled()
                    .disabled(viewModel.isLoading)
                    .placeholder(when: viewModel.seed.isEmpty) {
                        Text(LocalizedStrings.seed)
                            .foregroundColor(.placeholderText)
                            .font(.system(size: Layout.textFieldFontSize))
                    }
                    .overlay(
                        Rectangle()
                            .frame(height: Layout.separatorHeight)
                            .foregroundColor(.separatorTextField),
                        alignment: .bottom
                    )
            }
            .padding(.horizontal, Layout.horizontalPadding)

            Spacer().frame(height: Layout.inputBottomSpacing)

            // Language switch
            LanguageSegmentedControl(style: .full)
                .frame(height: 40)
                .padding(.horizontal, Layout.buttonHorizontalPadding)
                .disabled(viewModel.isLoading)

            Spacer().frame(height: Layout.languageSwitchBottomSpacing)

            // Separator line
            Rectangle()
                .fill(Color.separatorPrimary)
                .frame(height: Layout.separatorHeight)

            Spacer().frame(height: Layout.separatorBottomSpacing)

            // Confirm button
            PrimaryButton(
                title: LocalizedStrings.signIn,
                isEnabled: viewModel.isConfirmEnabled
            ) {
                viewModel.confirmTapped()
            }
            .padding(.horizontal, Layout.buttonHorizontalPadding)
            .padding(.bottom, Layout.buttonBottomPadding)
        }
        .onTapGesture {
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        }
    }
}

// MARK: - Layout Constants

private extension AuthView {
    enum Layout {
        // Logo
        static let logoHeight: CGFloat = 23
        static let logoBottomSpacing: CGFloat = 32

        // Illustration
        static let illustrationBottomSpacing: CGFloat = 82

        // Title
        static let titleFontSize: CGFloat = 28
        static let titleBottomSpacing: CGFloat = 24

        // Input
        static let labelFontSize: CGFloat = 14
        static let textFieldFontSize: CGFloat = 16
        static let textFieldVerticalPadding: CGFloat = 8
        static let horizontalPadding: CGFloat = 28
        static let inputBottomSpacing: CGFloat = 88

        // Language Switch
        static let languageSwitchBottomSpacing: CGFloat = 14

        // Separator
        static let separatorHeight: CGFloat = 1
        static let separatorBottomSpacing: CGFloat = 14

        // Button
        static let buttonHorizontalPadding: CGFloat = 14
        static let buttonBottomPadding: CGFloat = 16
    }
}

#Preview {
    AuthView()
}
