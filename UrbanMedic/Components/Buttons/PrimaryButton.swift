//
//  PrimaryButton.swift
//  UrbanMedic
//
//  Created by Demain Petropavlov on 31.01.2026.
//

import SwiftUI

struct PrimaryButton: View {
    let title: String
    let isEnabled: Bool
    let action: () -> Void

    private var backgroundGradient: LinearGradient {
        isEnabled
        ? .primaryButtonActive
        : .primaryButtonDisabled
    }

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 48)
                .background(backgroundGradient)
                .cornerRadius(6)
        }
        .disabled(!isEnabled)
    }
}

#Preview("Primary Button States") {
    VStack(spacing: 20) {

        PrimaryButton(
            title: "Подтвердить",
            isEnabled: true
        ) {}

        PrimaryButton(
            title: "Подтвердить",
            isEnabled: false
        ) {}
    }
    .padding()
    .background(Color(.systemBackground))
}
