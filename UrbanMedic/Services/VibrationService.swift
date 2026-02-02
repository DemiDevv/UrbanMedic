//
//  VibrationService.swift
//  UrbanMedic
//
//  Created by Demain Petropavlov on 02.02.2026.
//

import UIKit

final class VibrationService {

    static let shared = VibrationService()

    private init() {}

    func triggerVibration() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }
}
