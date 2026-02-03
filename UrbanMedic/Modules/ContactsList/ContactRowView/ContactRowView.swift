//
//  ContactRowView.swift
//  UrbanMedic
//
//  Created by Demain Petropavlov on 01.02.2026.
//

import SwiftUI

struct ContactRowView: View {

    let number: Int
    let contact: ContactModel
    let onEdit: (() -> Void)?

    var body: some View {
        HStack(spacing: 0) {
            // Number
            Text("\(number)")
                .padding(.leading, Layout.textPadding)
                .frame(width: Layout.numberColumnWidth, alignment: .leading)
                .font(.system(size: Layout.fontSize))

            // Vertical divider
            Divider()

            // Last Name
            Text(contact.lastName)
                .padding(.leading, Layout.textPadding)
                .frame(width: Layout.lastNameColumnWidth, alignment: .leading)
                .font(.system(size: Layout.fontSize))
                .lineLimit(1)

            // Vertical divider
            Divider()

            // Email
            HStack(spacing: 0) {
                Text(contact.email)
                    .padding(.leading, Layout.textPadding)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .font(.system(size: Layout.fontSize))
                    .lineLimit(1)
                    .truncationMode(.tail)

                // Edit button (if user created)
                if onEdit != nil {
                    Button(action: { onEdit?() }) {
                        Image(Constants.Images.editIcon)
                            .resizable()
                            .scaledToFit()
                            .frame(width: Layout.editIconSize, height: Layout.editIconSize)
                            .foregroundColor(.gray)
                    }
                    .padding(.trailing, Layout.editButtonTrailing)
                }
            }
        }
        .frame(height: Layout.rowHeight)
        .background(Color.white)
    }
}

// MARK: - Layout Constants

private extension ContactRowView {
    enum Layout {
        static let numberColumnWidth: CGFloat = 51
        static let lastNameColumnWidth: CGFloat = 130
        static let textPadding: CGFloat = 12
        static let fontSize: CGFloat = 12
        static let editIconSize: CGFloat = 18
        static let editButtonTrailing: CGFloat = 9
        static let rowHeight: CGFloat = 36
    }
}

#Preview {
    VStack(spacing: 0) {
        ContactRowView(
            number: 1,
            contact: ContactModel(lastName: "Алексеев", email: "gorodgrosh@yandex.ru", isUserCreated: true),
            onEdit: {}
        )
        Divider()
        ContactRowView(
            number: 2,
            contact: ContactModel(lastName: "Иванов", email: "test@example.com", isUserCreated: false),
            onEdit: nil
        )
    }
}
