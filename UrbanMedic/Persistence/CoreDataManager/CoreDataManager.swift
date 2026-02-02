//
//  CoreDataManager.swift
//  UrbanMedic
//
//  Created by Demain Petropavlov on 02.02.2026.
//

import Foundation
import CoreData
import Combine

final class CoreDataManager {

    static let shared = CoreDataManager()

    private init() {}

    // MARK: - Core Data Stack

    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "UrbanMedic")

        container.loadPersistentStores { description, error in
            if let error = error {
                fatalError("Unable to load persistent stores: \(error)")
            }
        }

        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy

        return container
    }()

    var context: NSManagedObjectContext {
        return persistentContainer.viewContext
    }

    // MARK: - Save Context

    func saveContext() {
        let context = persistentContainer.viewContext

        if context.hasChanges {
            do {
                try context.save()
            } catch {
                print("Error saving context: \(error)")
            }
        }
    }

    // MARK: - Session Management

    func saveSession(seed: String, cityName: String?) {
        // Удаляем старую сессию если есть
        deleteSession()

        let session = UserSessionEntity(context: context)
        session.id = "current_session"
        session.seed = seed
        session.cityName = cityName
        session.lastLoginDate = Date()

        saveContext()
    }

    func getCurrentSession() -> UserSessionEntity? {
        let request = NSFetchRequest<UserSessionEntity>(entityName: "UserSessionEntity")
        request.predicate = NSPredicate(format: "id == %@", "current_session")

        do {
            return try context.fetch(request).first
        } catch {
            print("Error fetching session: \(error)")
            return nil
        }
    }

    func deleteSession() {
        guard let session = getCurrentSession() else { return }
        context.delete(session)
        saveContext()
    }

    // MARK: - Contact Management

    func saveContact(_ contact: ContactModel, seed: String) {
        // Проверяем, существует ли контакт
        if let existingContact = fetchContactEntity(by: contact.id) {
            // Обновляем существующий
            existingContact.lastName = contact.lastName
            existingContact.email = contact.email
        } else {
            // Создаем новый
            let entity = ContactEntity(context: context)
            entity.id = contact.id.uuidString
            entity.lastName = contact.lastName
            entity.email = contact.email
            entity.isUserCreated = contact.isUserCreated
            entity.seed = seed
            entity.createdAt = Date()
        }

        saveContext()
    }

    func getContacts(for seed: String) -> [ContactModel] {
        let request = NSFetchRequest<ContactEntity>(entityName: "ContactEntity")
        request.predicate = NSPredicate(format: "seed == %@", seed)
        request.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: true)]

        do {
            let entities = try context.fetch(request)
            return entities.map { entity in
                ContactModel(
                    id: UUID(uuidString: entity.id ?? "") ?? UUID(),
                    lastName: entity.lastName ?? "",
                    email: entity.email ?? "",
                    isUserCreated: entity.isUserCreated
                )
            }
        } catch {
            print("Error fetching contacts: \(error)")
            return []
        }
    }

    func getUserCreatedContacts(for seed: String) -> [ContactModel] {
        let request = NSFetchRequest<ContactEntity>(entityName: "ContactEntity")
        request.predicate = NSPredicate(format: "seed == %@ AND isUserCreated == true", seed)
        request.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: true)]

        do {
            let entities = try context.fetch(request)
            return entities.map { entity in
                ContactModel(
                    id: UUID(uuidString: entity.id ?? "") ?? UUID(),
                    lastName: entity.lastName ?? "",
                    email: entity.email ?? "",
                    isUserCreated: entity.isUserCreated
                )
            }
        } catch {
            print("Error fetching user created contacts: \(error)")
            return []
        }
    }

    func deleteContact(_ contact: ContactModel) {
        guard let entity = fetchContactEntity(by: contact.id) else { return }
        context.delete(entity)
        saveContext()
    }

    func deleteAllContacts(for seed: String) {
        let request = NSFetchRequest<ContactEntity>(entityName: "ContactEntity")
        request.predicate = NSPredicate(format: "seed == %@", seed)

        do {
            let entities = try context.fetch(request)
            entities.forEach { context.delete($0) }
            saveContext()
        } catch {
            print("Error deleting all contacts: \(error)")
        }
    }

    func updateContact(_ contact: ContactModel, seed: String) {
        saveContact(contact, seed: seed)
    }

    // MARK: - Clear All Data

    func clearAllData() {
        let entityNames = ["ContactEntity", "UserSessionEntity"]

        for entityName in entityNames {
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
            let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)

            do {
                try context.execute(deleteRequest)
            } catch {
                print("Error clearing \(entityName): \(error)")
            }
        }

        // Reset context to sync with persistent store after batch delete
        context.reset()
    }

    // MARK: - Helper Methods

    private func fetchContactEntity(by id: UUID) -> ContactEntity? {
        let request = NSFetchRequest<ContactEntity>(entityName: "ContactEntity")
        request.predicate = NSPredicate(format: "id == %@", id.uuidString)

        do {
            return try context.fetch(request).first
        } catch {
            print("Error fetching contact entity: \(error)")
            return nil
        }
    }
}
