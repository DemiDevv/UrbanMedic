//
//  AuthView.swift
//  UrbanMedic
//
//  Created by Demain Petropavlov on 01.02.2026.
//

import SwiftUI

struct AuthView: View {

    @StateObject private var viewModel: AuthViewModel
    @EnvironmentObject private var appState: AppState

    init(viewModel: AuthViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                // Logo
                Image(Constants.Images.logo)
                    .resizable()
                    .scaledToFit()
                    .frame(height: Layout.logoHeight)
                    .padding(.bottom, Layout.logoBottomSpacing)

                // Illustration
                Image(Constants.Images.doctorIllustration)
                    .resizable()
                    .scaledToFit()
                    .padding(.bottom, Layout.illustrationBottomSpacing)

                // Title
                Text(LocalizedStrings.seed)
                    .font(.system(size: Layout.titleFontSize, weight: .regular))
                    .padding(.bottom, Layout.titleBottomSpacing)

                // Input field
                VStack(alignment: .leading, spacing: 0) {
                    Text(LocalizedStrings.seedLabel)
                        .font(.system(size: Layout.labelFontSize))
                        .foregroundColor(viewModel.seed.isEmpty ? .labelSecondary : .brandBlue)

                    TextField(LocalizedStrings.enterSeed, text: $viewModel.seed)
                        .font(.system(size: Layout.textFieldFontSize))
                        .foregroundColor(.placeholderText)
                        .padding(.vertical, Layout.textFieldVerticalPadding)
                        .autocapitalization(.none)
                        .autocorrectionDisabled()
                        .disabled(viewModel.isLoading)
                        .placeholder(when: viewModel.seed.isEmpty) {
                            Text(LocalizedStrings.enterSeed)
                                .foregroundColor(.placeholderText)
                                .font(.system(size: Layout.textFieldFontSize))
                        }
                        .overlay(
                            Rectangle()
                                .frame(height: Layout.separatorHeight)
                                .foregroundColor(viewModel.seed.isEmpty ? .separatorTextField : .brandBlue),
                            alignment: .bottom
                        )
                }
                .padding(.horizontal, Layout.horizontalPadding)
                .padding(.bottom, Layout.inputBottomSpacing)

                // Language switcher
                LanguageSegmentedControl(selectedLanguage: $appState.selectedLanguage, style: .full)
                    .frame(height: 40)
                    .padding(.horizontal, Layout.buttonHorizontalPadding)
                    .padding(.bottom, Layout.languageSwitchBottomSpacing)
                    .disabled(viewModel.isLoading)

                // Separator
                Rectangle()
                    .fill(Color.separatorPrimary)
                    .frame(height: Layout.separatorHeight)
                    .padding(.bottom, Layout.separatorBottomSpacing)

                // Sign in button
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

            // Loading overlay
            if viewModel.isLoading {
                Color.black.opacity(0.3)
                    .ignoresSafeArea()

                ProgressView()
                    .scaleEffect(1.5)
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
            }
        }
        .allowsHitTesting(!viewModel.isLoading)
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

        // Input fields
        static let labelFontSize: CGFloat = 14
        static let textFieldFontSize: CGFloat = 16
        static let textFieldVerticalPadding: CGFloat = 8
        static let horizontalPadding: CGFloat = 28
        static let inputBottomSpacing: CGFloat = 88

        // Language switcher
        static let languageSwitchBottomSpacing: CGFloat = 14

        // Separator
        static let separatorHeight: CGFloat = 1
        static let separatorBottomSpacing: CGFloat = 14

        // Button
        static let buttonHorizontalPadding: CGFloat = 14
        static let buttonBottomPadding: CGFloat = 16
    }
}
