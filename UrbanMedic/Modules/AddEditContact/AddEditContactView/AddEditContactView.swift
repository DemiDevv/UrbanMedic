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
            case .add: return Constants.ContactEdit.newContactTitle
            case .edit: return Constants.ContactEdit.editContactTitle
            }
        }

        var buttonTitle: String {
            switch self {
            case .add: return Constants.ContactEdit.addButton
            case .edit: return Constants.ContactEdit.saveButton
            }
        }
    }

    @StateObject private var viewModel: AddEditContactViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var showCloseAlert = false

    init(mode: Mode) {
        _viewModel = StateObject(wrappedValue: AddEditContactViewModel(mode: mode))
    }

    var body: some View {
        VStack(spacing: 0) {
            // Header
            headerView

            Spacer().frame(height: Layout.headerBottomSpacing)

            // Inputs
            inputsView

            Spacer()

            // Save/Add Button
            actionButton
        }
        .background(Color.white)
        .alert(Constants.ContactEdit.closeAlertTitle, isPresented: $showCloseAlert) {
            Button(Constants.ContactEdit.closeAlertCancel, role: .cancel) { }
            Button(Constants.ContactEdit.closeAlertConfirm, role: .destructive) {
                dismiss()
            }
        } message: {
            Text(Constants.ContactEdit.closeAlertMessage)
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
            // Last Name
            VStack(alignment: .leading, spacing: 0) {
                TextField(Constants.ContactEdit.lastNamePlaceholder, text: $viewModel.lastName)
                    .font(.system(size: Layout.inputFontSize))
                    .foregroundColor(.black)
                    .autocapitalization(.words)
                    .autocorrectionDisabled()
                    .padding(.vertical, Layout.inputVerticalPadding)
                    .overlay(
                        Rectangle()
                            .frame(height: Layout.separatorHeight)
                            .foregroundColor(.separatorTextField),
                        alignment: .bottom
                    )
            }

            // Email
            VStack(alignment: .leading, spacing: 0) {
                TextField(Constants.ContactEdit.emailPlaceholder, text: $viewModel.email)
                    .font(.system(size: Layout.inputFontSize))
                    .foregroundColor(.black)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                    .autocorrectionDisabled()
                    .padding(.vertical, Layout.inputVerticalPadding)
                    .overlay(
                        Rectangle()
                            .frame(height: Layout.separatorHeight)
                            .foregroundColor(.separatorTextField),
                        alignment: .bottom
                    )
            }
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
            dismiss()
        }
        .padding(.horizontal, Layout.buttonHorizontalPadding)
        .padding(.bottom, Layout.buttonBottomPadding)
    }
}

// MARK: - Layout Constants

private extension AddEditContactView {
    enum Layout {
        // Header
        static let headerHorizontalPadding: CGFloat = 14
        static let headerTopPadding: CGFloat = 24
        static let headerBottomSpacing: CGFloat = 20
        static let titleFontSize: CGFloat = 20
        static let closeIconSize: CGFloat = 24

        // Inputs
        static let inputsHorizontalPadding: CGFloat = 17
        static let inputVerticalPadding: CGFloat = 15
        static let inputsSpacing: CGFloat = 16
        static let inputFontSize: CGFloat = 16
        static let separatorHeight: CGFloat = 1

        // Button
        static let buttonHorizontalPadding: CGFloat = 16
        static let buttonBottomPadding: CGFloat = 16
    }
}

#Preview("Add Mode") {
    AddEditContactView(mode: .add)
}

#Preview("Edit Mode") {
    let contact = ContactModel(id: UUID(), lastName: "Иванов", email: "ivanov@test.com", isUserCreated: true)
    AddEditContactView(mode: .edit(contact))
}
