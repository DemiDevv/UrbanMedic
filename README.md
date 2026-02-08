# UrbanMedic

iOS приложение для управления контактами с поддержкой геолокации и локальных уведомлений.

## Требования

- iOS 16.0+
- Xcode 15.0+
- Swift 5.9+

## Архитектура

Проект построен на архитектуре **MVVM** с использованием **Dependency Injection**.

```
UrbanMedic/
├── App/                          # Точка входа и DI контейнер
│   ├── UrbanMedicApp.swift
│   ├── AppState.swift            # Глобальное состояние приложения
│   └── DependencyContainer.swift # Контейнер зависимостей
│
├── Modules/                      # Функциональные модули
│   ├── Auth/                     # Аутентификация
│   ├── ContactsList/             # Список контактов
│   └── AddEditContact/           # Добавление/редактирование контакта
│
├── Services/                     # Бизнес-сервисы
│   ├── LocationService.swift     # Геолокация
│   ├── NotificationService.swift # Локальные уведомления
│   └── VibrationService.swift    # Тактильная обратная связь
│
├── Network/                      # Сетевой слой
│   ├── NetworkManager.swift      # HTTP клиент (Alamofire)
│   ├── APIEndpoint.swift         # Endpoints
│   └── DTO/                      # Data Transfer Objects
│
├── Persistence/                  # Хранение данных
│   └── CoreDataManager/          # Core Data
│
├── Models/                       # Доменные модели
├── Components/                   # Переиспользуемые UI компоненты
├── Helpers/                      # Утилиты и расширения
└── Navigation/                   # Навигация
```

## Технологии

| Технология | Описание |
|------------|----------|
| SwiftUI | Пользовательский интерфейс |
| Combine | Реактивное программирование |
| async/await | Асинхронные операции |
| Core Data | Локальное хранение данных |
| Core Location | Геолокация |
| Alamofire | HTTP клиент |

## Функциональность

- Аутентификация по seed-фразе
- Загрузка контактов из RandomUser API с пагинацией
- Создание и редактирование пользовательских контактов
- Валидация полей (фамилия, email)
- Определение города по геолокации (Dadata API)
- Локальные уведомления
- Поддержка русского и английского языков

## Dependency Injection

Все зависимости инжектируются через `DependencyContainer`:

```swift
final class DependencyContainer: ObservableObject {
    let dataManager: DataManaging
    let networkManager: NetworkManaging
    let locationService: LocationProviding
    let notificationService: NotificationProviding
    let vibrationService: VibrationProviding
    let appState: AppState
}
```

Сервисы определены через протоколы, что упрощает тестирование:

- `DataManaging` — работа с Core Data
- `NetworkManaging` — сетевые запросы
- `LocationProviding` — геолокация
- `NotificationProviding` — уведомления
- `VibrationProviding` — вибрация

## Тестирование

### Структура тестов

```
UrbanMedicTests/
├── Mocks/
│   └── MockServices.swift           # Моки всех сервисов
├── ViewModels/
│   ├── AuthViewModelTests.swift
│   ├── ContactsListViewModelTests.swift
│   └── AddEditContactViewModelTests.swift
└── Models/
    ├── ContactModelTests.swift
    └── UserDTOTests.swift
```

### Запуск тестов

```bash
# Через Xcode
⌘ + U

# Через командную строку
xcodebuild test -scheme UrbanMedic -destination 'platform=iOS Simulator,name=iPhone 15'
```

### Покрытие

| Компонент | Тесты |
|-----------|-------|
| AddEditContactViewModel | Валидация, сохранение, редактирование |
| AuthViewModel | Auth flow, геолокация, уведомления |
| ContactsListViewModel | Загрузка, пагинация, logout |
| ContactModel | Identifiable, Hashable, Equatable |
| UserDTO | JSON декодирование, маппинг |

## API

### RandomUser API

Загрузка случайных контактов:
```
GET https://randomuser.me/api/?results=20&page=1&seed={seed}
```

### Dadata API

Определение города по координатам:
```
POST https://suggestions.dadata.ru/suggestions/api/4_1/rs/geolocate/address
```

## Сборка

1. Клонируйте репозиторий
2. Откройте `UrbanMedic.xcodeproj` в Xcode
3. Выберите симулятор или устройство
4. Нажмите `⌘ + R` для запуска

## Лицензия

MIT License
