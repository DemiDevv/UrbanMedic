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
        ZStack {
            VStack(spacing: 0) {
                // Логотип
                Image(Constants.Images.logo)
                    .resizable()
                    .scaledToFit()
                    .frame(height: Layout.logoHeight)

                Spacer().frame(height: Layout.logoBottomSpacing)

                // Иллюстрация
                Image(Constants.Images.doctorIllustration)
                    .resizable()
                    .scaledToFit()

                Spacer().frame(height: Layout.illustrationBottomSpacing)

                // Заголовок
                Text(LocalizedStrings.seed)
                    .font(.system(size: Layout.titleFontSize, weight: .regular))

                Spacer().frame(height: Layout.titleBottomSpacing)

                // Поле ввода
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

                Spacer().frame(height: Layout.inputBottomSpacing)

                // Переключатель языка
                LanguageSegmentedControl(style: .full)
                    .frame(height: 40)
                    .padding(.horizontal, Layout.buttonHorizontalPadding)
                    .disabled(viewModel.isLoading)

                Spacer().frame(height: Layout.languageSwitchBottomSpacing)

                // Разделитель
                Rectangle()
                    .fill(Color.separatorPrimary)
                    .frame(height: Layout.separatorHeight)

                Spacer().frame(height: Layout.separatorBottomSpacing)

                // Кнопка входа
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

            // Оверлей загрузки
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
        // Логотип
        static let logoHeight: CGFloat = 23
        static let logoBottomSpacing: CGFloat = 32

        // Иллюстрация
        static let illustrationBottomSpacing: CGFloat = 82

        // Заголовок
        static let titleFontSize: CGFloat = 28
        static let titleBottomSpacing: CGFloat = 24

        // Поля ввода
        static let labelFontSize: CGFloat = 14
        static let textFieldFontSize: CGFloat = 16
        static let textFieldVerticalPadding: CGFloat = 8
        static let horizontalPadding: CGFloat = 28
        static let inputBottomSpacing: CGFloat = 88

        // Переключатель языка
        static let languageSwitchBottomSpacing: CGFloat = 14

        // Разделитель
        static let separatorHeight: CGFloat = 1
        static let separatorBottomSpacing: CGFloat = 14

        // Кнопка
        static let buttonHorizontalPadding: CGFloat = 14
        static let buttonBottomPadding: CGFloat = 16
    }
}

#Preview {
    AuthView()
}
