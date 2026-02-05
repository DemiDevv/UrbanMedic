//
//  AddEditContactView.swift
//  UrbanMedic
//
//  Created by Demain Petropavlov on 01.02.2026.
//

import SwiftUI

struct AddEditContactView: View {

    enum Mode {
        case add
        case edit(ContactModel)

        var title: String {
            switch self {
            case .add: return LocalizedStrings.newContact
            case .edit: return LocalizedStrings.edit
            }
        }

        var buttonTitle: String {
            switch self {
            case .add: return LocalizedStrings.addContact
            case .edit: return LocalizedStrings.save
            }
        }
    }

    @StateObject private var viewModel: AddEditContactViewModel
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var appState: AppState
    @State private var showCloseAlert = false

    private let onSave: (() -> Void)?

    init(mode: Mode, onSave: (() -> Void)? = nil) {
        _viewModel = StateObject(wrappedValue: AddEditContactViewModel(mode: mode))
        self.onSave = onSave
    }

    var body: some View {
        VStack(spacing: 0) {
            headerView
                .padding(.bottom, Layout.headerBottomSpacing)

            inputsView

            Spacer()

            actionButton
        }
        .background(Color.white)
        .alert(LocalizedStrings.areYouSure, isPresented: $showCloseAlert) {
            Button(LocalizedStrings.cancel, role: .cancel) { }
            Button(LocalizedStrings.exit, role: .destructive) {
                dismiss()
            }
        } message: {
            Text(LocalizedStrings.informationWillNotBeSaved)
        }
    }

    // MARK: - Header

    private var headerView: some View {
        HStack {
            Text(viewModel.mode.title)
                .font(.system(size: Layout.titleFontSize, weight: .semibold))

            Spacer()

            Button {
                if viewModel.hasChanges {
                    showCloseAlert = true
                } else {
                    dismiss()
                }
            } label: {
                Image(Constants.Images.xmarkIcon)
                    .font(.system(size: Layout.closeIconSize, weight: .medium))
                    .foregroundColor(.black)
            }
        }
        .padding(.horizontal, Layout.headerHorizontalPadding)
        .padding(.top, Layout.headerTopPadding)
    }

    // MARK: - Inputs

    private var inputsView: some View {
        VStack(alignment: .leading, spacing: Layout.inputsSpacing) {
            ValidationTextField(
                placeholder: LocalizedStrings.lastName,
                text: $viewModel.lastName,
                showError: viewModel.showLastNameError,
                keyboardType: .default,
                capitalization: .words
            )

            ValidationTextField(
                placeholder: LocalizedStrings.email,
                text: $viewModel.email,
                showError: viewModel.showEmailError,
                keyboardType: .emailAddress,
                capitalization: .never
            )
        }
        .padding(.horizontal, Layout.inputsHorizontalPadding)
    }

    // MARK: - Action Button

    private var actionButton: some View {
        PrimaryButton(
            title: viewModel.mode.buttonTitle,
            isEnabled: viewModel.isValid
        ) {
            viewModel.save()
            onSave?()
            dismiss()
        }
        .padding(.horizontal, Layout.buttonHorizontalPadding)
        .padding(.bottom, Layout.buttonBottomPadding)
    }
}

// MARK: - Layout Constants

private extension AddEditContactView {
    enum Layout {
        // Заголовок
        static let headerHorizontalPadding: CGFloat = 14
        static let headerTopPadding: CGFloat = 24
        static let headerBottomSpacing: CGFloat = 20
        static let titleFontSize: CGFloat = 20
        static let closeIconSize: CGFloat = 24

        // Поля ввода
        static let inputsHorizontalPadding: CGFloat = 17
        static let inputVerticalPadding: CGFloat = 15
        static let inputsSpacing: CGFloat = 16
        static let inputFontSize: CGFloat = 16
        static let separatorHeight: CGFloat = 1

        // Кнопка
        static let buttonHorizontalPadding: CGFloat = 16
        static let buttonBottomPadding: CGFloat = 16
    }
}

#Preview("Add Mode") {
    AddEditContactView(mode: .add)
        .environmentObject(AppState.shared)
}

#Preview("Edit Mode") {
    let contact = ContactModel(id: UUID(), lastName: "Иванов", email: "ivanov@test.com", isUserCreated: true)
    AddEditContactView(mode: .edit(contact))
        .environmentObject(AppState.shared)
}
