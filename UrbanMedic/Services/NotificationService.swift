//
//  NotificationService.swift
//  UrbanMedic
//
//  Created by Demain Petropavlov on 02.02.2026.
//

import Foundation
import UserNotifications

final class NotificationService: NSObject {

    static let shared = NotificationService()

    private override init() {
        super.init()
        // Set delegate to show notifications in foreground
        UNUserNotificationCenter.current().delegate = self
    }

    // MARK: - Request Permission

    func requestPermission(completion: @escaping (Bool) -> Void) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { granted, error in
            if let error = error {
                print("Error requesting notification permission: \(error)")
            }
            DispatchQueue.main.async {
                completion(granted)
            }
        }
    }

    // MARK: - Send Local Notification

    func sendLocalNotification(title: String, body: String? = nil) {
        let content = UNMutableNotificationContent()
        content.title = title
        if let body = body {
            content.body = body
        }
        content.sound = .default

        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: nil // Показать сразу
        )

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error sending notification: \(error)")
            }
        }
    }
}

// MARK: - UNUserNotificationCenterDelegate

extension NotificationService: UNUserNotificationCenterDelegate {

    // Show notification even when app is in foreground
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.banner, .sound])
    }
}
