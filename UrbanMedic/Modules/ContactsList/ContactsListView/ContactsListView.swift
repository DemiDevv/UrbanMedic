//
//  ContactsListView.swift
//  UrbanMedic
//
//  Created by Demain Petropavlov on 01.02.2026.
//

import SwiftUI

struct ContactsListView: View {

    @StateObject private var viewModel = ContactsListViewModel()
    @EnvironmentObject private var appState: AppState

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
        .sheet(isPresented: $viewModel.shouldNavigateToAddContact) {
            if let contact = viewModel.contactToEdit {
                AddEditContactView(mode: .edit(contact)) {
                    viewModel.refreshContacts()
                }
            } else {
                AddEditContactView(mode: .add) {
                    viewModel.refreshContacts()
                }
            }
        }
        .alert(LocalizedStrings.areYouSure, isPresented: $viewModel.showLogoutAlert) {
            Button(LocalizedStrings.cancel, role: .cancel) { }
            Button(LocalizedStrings.exit, role: .destructive) {
                viewModel.confirmLogout()
            }
        } message: {
            Text(LocalizedStrings.informationWillBeDeleted)
        }
    }

    // MARK: - Header

    private var shouldShowCity: Bool {
        !viewModel.cityName.isEmpty
    }

    private var headerView: some View {
        ZStack {
            if shouldShowCity {
                Text(viewModel.cityName)
                    .font(.system(size: Layout.cityFontSize, weight: .medium))
            }

            HStack {
                LanguageSegmentedControl(selectedLanguage: $appState.selectedLanguage, style: .short)
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
            tableHeaderView

            if viewModel.isLoading && viewModel.contacts.isEmpty {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(Array(viewModel.contacts.enumerated()), id: \.element.id) { index, contact in
                            ContactRowView(
                                number: index + 1,
                                contact: contact,
                                onEdit: contact.isUserCreated ? {
                                    viewModel.editContact(contact)
                                } : nil
                            )
                            .onAppear {
                                viewModel.loadMoreContactsIfNeeded(currentContact: contact)
                            }

                            Divider()
                        }

                        if viewModel.isLoading {
                            ProgressView()
                                .padding()
                        }
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

            Text(LocalizedStrings.lastName)
                .padding(.leading, Layout.tableHeaderPadding)
                .frame(width: Layout.lastNameColumnWidth, alignment: .leading)

            Divider()
                .frame(width: Layout.separatorHeight)
                .background(Color.white)

            Text(LocalizedStrings.email)
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
            title: LocalizedStrings.addContact,
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
        // Заголовок
        static let separatorHeight: CGFloat = 1
        static let headerLeadingPadding: CGFloat = 20
        static let headerTrailingPadding: CGFloat = 20
        static let headerVerticalPadding: CGFloat = 12
        static let headerHeight: CGFloat = 26
        static let languageSwitchWidth: CGFloat = 69
        static let languageSwitchHeight: CGFloat = 26
        static let cityFontSize: CGFloat = 17
        static let logoutIconSize: CGFloat = 24

        // Заголовок таблицы
        static let numberColumnWidth: CGFloat = 51
        static let lastNameColumnWidth: CGFloat = 130
        static let tableHeaderPadding: CGFloat = 12
        static let tableHeaderFontSize: CGFloat = 12
        static let tableHeaderVerticalPadding: CGFloat = 12
        static let tableHeaderHeight: CGFloat = 40

        // Кнопка
        static let buttonHorizontalPadding: CGFloat = 16
        static let buttonVerticalPadding: CGFloat = 16
    }
}

#Preview {
    ContactsListView()
        .environmentObject(AppState.shared)
}
