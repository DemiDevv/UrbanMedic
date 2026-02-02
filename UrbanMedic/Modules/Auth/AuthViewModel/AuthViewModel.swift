//
//  AuthViewModel.swift
//  UrbanMedic
//
//  Created by Demain Petropavlov on 01.02.2026.
//

import Foundation
import Combine

final class AuthViewModel: ObservableObject {

    @Published var seed: String = ""
    @Published var selectedLanguage: Language = .ru
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var shouldNavigateToContacts: Bool = false

    enum Language {
        case ru
        case en
    }

    private var cancellables = Set<AnyCancellable>()

    // MARK: - Initialization

    init() {
        checkExistingSession()
    }

    // MARK: - Computed Properties

    var isConfirmEnabled: Bool {
        !seed.trimmingCharacters(in: .whitespaces).isEmpty && !isLoading
    }

    // MARK: - Check Existing Session

    private func checkExistingSession() {
        if let session = CoreDataManager.shared.getCurrentSession() {
            // Пользователь уже авторизован, переходим к списку контактов
            self.seed = session.seed ?? ""
            self.shouldNavigateToContacts = true
        }
    }

    // MARK: - Confirm Button Action

    func confirmTapped() {
        guard isConfirmEnabled else { return }

        isLoading = true
        errorMessage = nil

        // 1. Сначала запрашиваем геолокацию
        requestLocationAndSaveSession()

        // Таймаут на случай если геолокация зависнет
        DispatchQueue.main.asyncAfter(deadline: .now() + 10) { [weak self] in
            guard let self = self else { return }
            if self.isLoading {
                print("Location request timeout")
                self.completeAuthFlow(cityName: nil)
            }
        }
    }

    // MARK: - Location & Save Session

    private func requestLocationAndSaveSession() {
        LocationService.shared.requestLocation()
            .mapError { error -> NetworkError in
                // Конвертируем Error в NetworkError
                return .unknown(error)
            }
            .flatMap { location -> AnyPublisher<String, NetworkError> in
                // Получаем название города по координатам
                return LocationService.shared.getCityName(for: location)
            }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                guard let self = self else { return }

                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    print("Location error: \(error.localizedDescription)")
                    // Даже если геолокация не удалась, продолжаем авторизацию
                    self.completeAuthFlow(cityName: nil)
                }
            } receiveValue: { [weak self] cityName in
                guard let self = self else { return }
                // Продолжаем авторизацию с названием города
                self.completeAuthFlow(cityName: cityName)
            }
            .store(in: &cancellables)
    }

    // MARK: - Complete Auth Flow

    private func completeAuthFlow(cityName: String?) {
        // Предотвращаем повторный вызов (например, от таймаута)
        guard isLoading else { return }

        // 2. Запрашиваем разрешение на уведомления
        NotificationService.shared.requestPermission { [weak self] granted in
            guard let self = self else { return }

            // 3. Вызываем вибрацию
            VibrationService.shared.triggerVibration()

            // 4. Отправляем уведомление (если разрешение дано)
            if granted {
                NotificationService.shared.sendLocalNotification(
                    title: "Вы успешно авторизовались"
                )
            }

            // 5. Сохраняем сессию
            self.saveSession(cityName: cityName)
        }
    }

    // MARK: - Save Session

    private func saveSession(cityName: String?) {
        CoreDataManager.shared.saveSession(
            seed: seed.trimmingCharacters(in: .whitespaces),
            cityName: cityName
        )

        isLoading = false
        shouldNavigateToContacts = true

        // Update global auth state
        AppState.shared.login()
    }

    // MARK: - Language Selection

    func selectLanguage(_ language: Language) {
        selectedLanguage = language
        // TODO: Применить локализацию
    }
}
