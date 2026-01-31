//
//  Gradient+Extension.swift
//  UrbanMedic
//
//  Created by Demain Petropavlov on 31.01.2026.
//

import SwiftUI

extension LinearGradient {

    static let primaryButtonActive = LinearGradient(
        colors: [
            .primaryButtonActiveStart,
            .primaryButtonActiveEnd
        ],
        startPoint: .leading,
        endPoint: .trailing
    )

    static let primaryButtonDisabled = LinearGradient(
        colors: [
            .primaryButtonDisabledStart,
            .primaryButtonDisabledEnd
        ],
        startPoint: .leading,
        endPoint: .trailing
    )
}
