//
//  ValidationTextField.swift
//  UrbanMedic
//
//  Created by Demain Petropavlov on 05.02.2026.
//

import SwiftUI

struct ValidationTextField: View {
    let placeholder: String
    @Binding var text: String
    let showError: Bool
    let keyboardType: UIKeyboardType
    let capitalization: TextInputAutocapitalization

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ZStack(alignment: .leading) {
                Text(text.isEmpty ? "\(placeholder)*" : text)
                    .font(.system(size: 16))
                    .foregroundColor(
                        text.isEmpty
                            ? .placeholderText
                            : (showError ? .red : .black)
                    )

                TextField("", text: $text)
                    .font(.system(size: 16))
                    .foregroundColor(.clear)
                    .keyboardType(keyboardType)
                    .textInputAutocapitalization(capitalization)
                    .autocorrectionDisabled()
                    .tint(showError ? .red : .blue)
            }
            .padding(.vertical, 15)
            .overlay(
                Rectangle()
                    .frame(height: 1)
                    .foregroundColor(showError ? .red : .separatorTextField),
                alignment: .bottom
            )
        }
    }
}
