//
//  CoreDataManager.swift
//  AnimalGallery
//
//  Created by Jayant Badlani on 15/08/24.
//

import Foundation
import CoreData

// MARK: - CoreDataManaging Protocol
protocol CoreDataManaging {
    func save(completion: @escaping (Error?) -> Void)
    func fetchFavorites(animalName: String?, completion: @escaping (Result<[FavoriteImage], Error>) -> Void)
    func addFavorite(imageURL: String, animalName: String, completion: @escaping (Error?) -> Void)
    func removeFavorite(imageURL: String, completion: @escaping (Error?) -> Void)
}


/// Manages Core Data operations for the application.
class CoreDataManager: CoreDataManaging {

    // MARK: - Core Data Stack
    private lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "AnimalGallery")
        container.loadPersistentStores { description, error in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
        return container
    }()

    private var context: NSManagedObjectContext {
        return persistentContainer.viewContext
    }

    // MARK: - Core Data Saving Support
    func save(completion: @escaping (Error?) -> Void) {
        if context.hasChanges {
            do {
                try context.save()
                completion(nil)
            } catch {
                completion(error)
            }
        } else {
            completion(nil)
        }
    }

    // MARK: - Core Data Fetching
    func fetchFavorites(animalName: String? = nil, completion: @escaping (Result<[FavoriteImage], Error>) -> Void) {
        let request: NSFetchRequest<FavoriteImage> = FavoriteImage.fetchRequest()
        if let name = animalName {
            request.predicate = NSPredicate(format: "animalName == %@", name)
        }
        do {
            let favorites = try context.fetch(request)
            completion(.success(favorites))
        } catch {
            print("Failed to fetch favorites: \(error.localizedDescription)")
            completion(.failure(error))
        }
    }

    // MARK: - Core Data Manipulation
    func addFavorite(imageURL: String, animalName: String, completion: @escaping (Error?) -> Void) {
        let favorite = FavoriteImage(context: context)
        favorite.url = imageURL
        favorite.animalName = animalName
        save(completion: completion)
    }

    // MARK: - Removes a favorite image from Core Data.
    func removeFavorite(imageURL: String, completion: @escaping (Error?) -> Void) {
        let request: NSFetchRequest<FavoriteImage> = FavoriteImage.fetchRequest()
        request.predicate = NSPredicate(format: "url == %@", imageURL)
        do {
            if let favorite = try context.fetch(request).first {
                context.delete(favorite)
                save(completion: completion)
            } else {
                completion(nil) // No error, just nothing to delete
            }
        } catch {
            print("Failed to remove favorite: \(error.localizedDescription)")
            completion(error)
        }
    }
}
