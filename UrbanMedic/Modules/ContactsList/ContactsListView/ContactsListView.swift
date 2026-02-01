//
//  ContactsListView.swift
//  UrbanMedic
//
//  Created by Demain Petropavlov on 01.02.2026.
//

import SwiftUI

struct ContactsListView: View {

    @StateObject private var viewModel = ContactsListViewModel()

    var body: some View {
        VStack(spacing: 0) {
            // Header
            headerView

            // Table
            tableView

            // Add Contact Button
            addContactButton
        }
        .background(Color.white)
    }

    // MARK: - Header

    private var headerView: some View {
        ZStack {
            Text(viewModel.cityName)
                .font(.system(size: Layout.cityFontSize, weight: .medium))

            HStack {
                LanguageSegmentedControl(
                    selectedLanguage: $viewModel.selectedLanguage,
                    style: .short
                )
                .frame(width: Layout.languageSwitchWidth, height: Layout.languageSwitchHeight)

                Spacer()

                Button(action: viewModel.logout) {
                    Image(Constants.Images.logoutIcon)
                        .resizable()
                        .frame(width: Layout.logoutIconSize, height: Layout.logoutIconSize)
                }
            }
            .padding(.leading, Layout.headerLeadingPadding)
            .padding(.trailing, Layout.headerTrailingPadding)
        }
        .frame(height: Layout.headerHeight)
        .padding(.vertical, Layout.headerVerticalPadding)
        .background(Color.white)
    }

    // MARK: - Table

    private var tableView: some View {
        VStack(spacing: 0) {
            // Table Header
            tableHeaderView

            // Table Content
            ScrollView {
                LazyVStack(spacing: 0) {
                    ForEach(Array(viewModel.contacts.enumerated()), id: \.offset) { index, contact in
                        ContactRowView(
                            number: index + 1,
                            contact: contact,
                            onEdit: contact.isUserCreated ? {
                                viewModel.editContact(contact)
                            } : nil
                        )

                        Divider()
                    }
                }
            }
        }
    }

    private var tableHeaderView: some View {
        HStack(spacing: 0) {
            Text(Constants.Contacts.numberColumn)
                .padding(.leading, Layout.tableHeaderPadding)
                .frame(width: Layout.numberColumnWidth, alignment: .leading)

            Divider()
                .frame(width: Layout.separatorHeight)
                .background(Color.white)

            Text(Constants.Contacts.lastNameColumn)
                .padding(.leading, Layout.tableHeaderPadding)
                .frame(maxWidth: .infinity, alignment: .leading)

            Divider()
                .frame(width: Layout.separatorHeight)
                .background(Color.white)

            Text(Constants.Contacts.emailColumn)
                .padding(.leading, Layout.tableHeaderPadding)
                .frame(maxWidth: .infinity, alignment: .leading)

        }
        .font(.system(size: Layout.tableHeaderFontSize, weight: .bold))
        .foregroundColor(.white)
        .frame(height: Layout.tableHeaderHeight)
        .background(Color.brandBlue)
    }

    // MARK: - Add Contact Button

    private var addContactButton: some View {
        PrimaryButton(
            title: Constants.Contacts.addContactButton,
            isEnabled: true
        ) {
            viewModel.addContactTapped()
        }
        .padding(.horizontal, Layout.buttonHorizontalPadding)
        .padding(.vertical, Layout.buttonVerticalPadding)
        .background(Color.white)
    }
}

// MARK: - Layout Constants

private extension ContactsListView {
    enum Layout {
        // Header
        static let separatorHeight: CGFloat = 1
        static let headerLeadingPadding: CGFloat = 20
        static let headerTrailingPadding: CGFloat = 20
        static let headerVerticalPadding: CGFloat = 12
        static let headerHeight: CGFloat = 26
        static let languageSwitchWidth: CGFloat = 69
        static let languageSwitchHeight: CGFloat = 26
        static let cityFontSize: CGFloat = 17
        static let logoutIconSize: CGFloat = 24

        // Table Header
        static let numberColumnWidth: CGFloat = 51
        static let tableHeaderPadding: CGFloat = 12
        static let tableHeaderFontSize: CGFloat = 12
        static let tableHeaderVerticalPadding: CGFloat = 12
        static let tableHeaderHeight: CGFloat = 48

        // Button
        static let buttonHorizontalPadding: CGFloat = 16
        static let buttonVerticalPadding: CGFloat = 16
    }
}

#Preview {
    ContactsListView()
}
