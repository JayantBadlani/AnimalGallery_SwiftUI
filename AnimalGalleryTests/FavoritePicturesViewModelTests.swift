//
//  FavoritePicturesViewModelTests.swift
//  AnimalGalleryTests
//
//  Created by Jayant Badlani on 16/08/24.
//

import XCTest
import CoreData
@testable import AnimalGallery

class FavoritePicturesViewModelTests: XCTestCase {
    
    var viewModel: FavoritePicturesViewModel!
    var mockCoreDataManager: MockCoreDataManager!
    var context: NSManagedObjectContext!
    
    override func setUp() {
        super.setUp()
        // Initialize Core Data stack for testing
        let persistentContainer = NSPersistentContainer(name: "AnimalGallery")
        persistentContainer.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Failed to load persistent stores: \(error)")
            }
        }
        context = persistentContainer.viewContext
        mockCoreDataManager = MockCoreDataManager(context: context)
        viewModel = FavoritePicturesViewModel(coreDataManager: mockCoreDataManager)
    }
    
    override func tearDown() {
        viewModel = nil
        mockCoreDataManager = nil
        context = nil
        super.tearDown()
    }
    
    func testLoadFavoritesSuccess() {
        // Given
        let favoriteImage = createFavoriteImage(animalName: "Lion", url: "https://example.com/lion.jpg")
        mockCoreDataManager.fetchFavoritesResult = .success([favoriteImage])
        
        // When
        let expectation = self.expectation(description: "Load favorites")
        viewModel.loadFavorites()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            expectation.fulfill()
        }
        waitForExpectations(timeout: 1.0)
        
        // Then
        XCTAssertEqual(viewModel.filteredImages.count, 1)
        XCTAssertEqual(viewModel.filteredImages.first?.animalName, "Lion")
        XCTAssertNil(viewModel.errorMessage)
    }
    
    func testLoadFavoritesFailure() {
        // Given
        let error = NSError(domain: "Test", code: 1, userInfo: nil)
        mockCoreDataManager.fetchFavoritesResult = .failure(error)
        
        // When
        let expectation = self.expectation(description: "Load favorites failure")
        viewModel.loadFavorites()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            expectation.fulfill()
        }
        waitForExpectations(timeout: 1.0)
        
        // Then
        XCTAssertNotNil(viewModel.errorMessage)
    }
    
    func testFilterFavorites() {
        // Given
        let lionImage = createFavoriteImage(animalName: "Lion", url: "https://example.com/lion.jpg")
        let tigerImage = createFavoriteImage(animalName: "Tiger", url: "https://example.com/tiger.jpg")
        mockCoreDataManager.fetchFavoritesResult = .success([lionImage, tigerImage])
        
        // When
        viewModel.filterFavorites(by: "Lion")
        
        // Add a short delay to allow asynchronous code to execute
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            // Then
            XCTAssertEqual(self.viewModel.filteredImages.count, 1)
            XCTAssertEqual(self.viewModel.filteredImages.first?.animalName, "Lion")
        }
    }

    
    func testPagination() {
        // Given
        let favoriteImages = (1...30).map { createFavoriteImage(animalName: "Animal \($0)", url: "https://example.com/animal\($0).jpg") }
        mockCoreDataManager.fetchFavoritesResult = .success(favoriteImages)
        
        // When
        viewModel.resetPagination()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.viewModel.fetchNextPage()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                // Then
                XCTAssertEqual(self.viewModel.filteredImages.count, 15) // First page
                XCTAssertTrue(self.viewModel.hasMorePages)
                
                self.viewModel.fetchNextPage()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    XCTAssertEqual(self.viewModel.filteredImages.count, 30) // Second page
                    XCTAssertFalse(self.viewModel.hasMorePages)
                }
            }
        }
    }
    
    func testResetPagination() {
        // Given
        let favoriteImage = createFavoriteImage(animalName: "Lion", url: "https://example.com/lion.jpg")
        mockCoreDataManager.fetchFavoritesResult = .success([favoriteImage])
        
        // When
        viewModel.resetPagination()
        
        // Then
        XCTAssertEqual(viewModel.filteredImages.count, 1)
        XCTAssertEqual(viewModel.getCurrentPage, 1)
    }
    
    func testFetchNextPageWithNoMorePages() {
        // Given
        let favoriteImage = createFavoriteImage(animalName: "Lion", url: "https://example.com/lion.jpg")
        mockCoreDataManager.fetchFavoritesResult = .success([favoriteImage])
        viewModel.hasMorePages = false
        
        // When
        viewModel.fetchNextPage()
        
        // Add a short delay to allow asynchronous code to execute
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            // Then
            XCTAssertEqual(self.viewModel.filteredImages.count, 1)
        }
    }

    
    // Helper to create a FavoriteImage instance
    private func createFavoriteImage(animalName: String, url: String) -> FavoriteImage {
        let favoriteImage = FavoriteImage(context: context)
        favoriteImage.animalName = animalName
        favoriteImage.url = url
        return favoriteImage
    }
    
    // MARK: - Mock Classes
    class MockCoreDataManager: CoreDataManaging {
        
        var fetchFavoritesResult: Result<[FavoriteImage], Error>?
        var addFavoriteError: Error?
        var removeFavoriteError: Error?
        var context: NSManagedObjectContext
        
        init(context: NSManagedObjectContext) {
            self.context = context
        }
        
        func addFavorite(imageURL: String, animalName: String, completion: @escaping (Error?) -> Void) {
            completion(addFavoriteError)
        }
        
        func fetchFavorites(animalName: String?, completion: @escaping (Result<[FavoriteImage], Error>) -> Void) {
            if let result = fetchFavoritesResult {
                completion(result)
            }
        }
        
        func removeFavorite(imageURL: String, completion: @escaping (Error?) -> Void) {
            completion(removeFavoriteError)
        }
        
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
    }
}
