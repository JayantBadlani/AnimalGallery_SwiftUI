//
//  AnimalPicturesViewModelTests.swift
//  AnimalGalleryTests
//
//  Created by Jayant Badlani on 16/08/24.
//


import XCTest
import CoreData
@testable import AnimalGallery


final class AnimalPicturesViewModelTests: XCTestCase {
    
    var viewModel: AnimalPicturesViewModel!
    var mockNetworkManager: MockNetworkManager!
    var mockCoreDataManager: MockCoreDataManager!
    var mockPersistentContainer: NSPersistentContainer!
    
    override func setUp() {
        super.setUp()
        mockNetworkManager = MockNetworkManager()
        
        mockPersistentContainer = NSPersistentContainer(name: "AnimalGallery")
        mockPersistentContainer.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        mockPersistentContainer.loadPersistentStores { (description, error) in
            XCTAssertNil(error)
        }
        mockCoreDataManager = MockCoreDataManager(context: mockPersistentContainer.viewContext)
        
        viewModel = AnimalPicturesViewModel(
            selectedAnimal: .dog,
            networkManager: mockNetworkManager,
            coreDataManager: mockCoreDataManager
        )
    }
    
    override func tearDown() {
        viewModel = nil
        mockNetworkManager = nil
        mockCoreDataManager = nil
        super.tearDown()
    }
    
    func testFetchAnimalDetailsSuccess() {
        // Given
        let expectedDetails = AnimalDetailsModel(name: "Dog", taxonomy: nil, locations: nil, characteristics: nil)
        mockNetworkManager.animalDetailsResult = .success(expectedDetails)
        
        // When
        let expectation = self.expectation(description: "Fetching animal details")
        viewModel.fetchAnimalDetails {
            expectation.fulfill()
        }
        waitForExpectations(timeout: 1.0, handler: nil)
        
        // Then
        XCTAssertEqual(viewModel.animalDetails?.name, "Dog")
        XCTAssertNil(viewModel.errorMessage)
    }
    
    func testFetchAnimalDetailsFailure() {
        // Given
        let expectedError = NSError(domain: "TestError", code: 1, userInfo: nil)
        mockNetworkManager.animalDetailsResult = .failure(expectedError)
        
        // When
        let expectation = self.expectation(description: "Fetching animal details")
        viewModel.fetchAnimalDetails {
            expectation.fulfill()
        }
        waitForExpectations(timeout: 1.0, handler: nil)
        
        // Then
        XCTAssertNotNil(viewModel.errorMessage)
    }
    
    func testFetchImagesSuccess() {
        // Given
        mockNetworkManager.animalPicturesResult = .success(
            AnimalPictureModel(page: 1, perPage: 15, photos: [
                Photo(id: nil, width: nil, height: nil, url: "https://example.com/dog1.jpg", photographer: nil, photographerURL: nil, photographerID: nil, avgColor: nil, src: Src(original: "", large2X: "", large: "https://example.com/dog1.jpg", medium: "", small: "", portrait: "", landscape: "", tiny: ""), liked: false, alt: nil)
            ], totalResults: 1, nextPage: nil)
        )
        
        // When
        let expectation = self.expectation(description: "Fetching animal images")
        viewModel.fetchImages {
            print("Fetched images: \(self.viewModel.images)")
            expectation.fulfill()
        }
        waitForExpectations(timeout: 1.0, handler: nil)
        
        // Then
        XCTAssertGreaterThan(viewModel.images.count, 0, "The number of images should be greater than 0.")
        XCTAssertNil(viewModel.errorMessage, "There should be no error message.")
    }
    
    func testFetchImagesFailure() {
        // Given
        let expectedError = NSError(domain: "TestError", code: 1, userInfo: nil)
        mockNetworkManager.animalPicturesResult = .failure(expectedError)
        
        // When
        let expectation = self.expectation(description: "Fetching animal images")
        viewModel.fetchImages {
            expectation.fulfill()
        }
        waitForExpectations(timeout: 1.0, handler: nil)
        
        // Then
        XCTAssertNotNil(viewModel.errorMessage)
        XCTAssertEqual(viewModel.images.count, 0)
    }
    
    func testToggleFavorite_AddsFavorite() {
        // Given
        let imageURL = "https://example.com/dog1.jpg"
        mockCoreDataManager.addFavoriteError = nil
        
        // When
        viewModel.toggleFavorite(imageURL: imageURL)
        print("Favorite Images after adding: \(viewModel.favoriteImages)")
        
        // Then
        XCTAssertTrue(viewModel.isFavorite(imageURL: imageURL), "Image should be marked as favorite after toggling.")
    }
    
    func testToggleFavorite_RemovesFavorite() {
        // Given
        let imageURL = "https://example.com/dog1.jpg"
        viewModel.favoriteImages = [imageURL]
        
        // When
        viewModel.toggleFavorite(imageURL: imageURL)
        print("Favorite Images after removing: \(viewModel.favoriteImages)")
        
        // Then
        XCTAssertFalse(viewModel.isFavorite(imageURL: imageURL), "Image should not be marked as favorite after toggling.")
    }
    
    func testLoadFavorites() {
        // Given
        let context = mockPersistentContainer.viewContext
        let favoriteImage = FavoriteImage(context: context)
        favoriteImage.url = "https://example.com/dog1.jpg"
        
        mockCoreDataManager.fetchFavoritesResult = .success([favoriteImage])
        
        // When
        viewModel.loadFavorites()
        
        // Then
        XCTAssertTrue(viewModel.isFavorite(imageURL: "https://example.com/dog1.jpg"))
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
        
        func fetchFavorites(animalName: String?, completion: @escaping (Result<[AnimalGallery.FavoriteImage], any Error>) -> Void) {
            if let result = fetchFavoritesResult {
                completion(result)
            }
        }
        
        func removeFavorite(imageURL: String, completion: @escaping (Error?) -> Void) {
            completion(removeFavoriteError)
        }
        
        func save(completion: @escaping ((any Error)?) -> Void) {
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
    
    // MARK: - Mock Classes
    class MockNetworkManager: NetworkManaging {
        var animalDetailsResult: Result<AnimalDetailsModel, Error>?
        var animalPicturesResult: Result<AnimalPictureModel, Error>?
        
        func fetchAnimalDetails(name: String, completion: @escaping (Result<AnimalDetailsModel, Error>) -> Void) {
            if let result = animalDetailsResult {
                completion(result)
            }
        }
        
        func fetchImages(for animal: String, page: Int, completion: @escaping (Result<AnimalPictureModel, Error>) -> Void) {
            if let result = animalPicturesResult {
                completion(result)
            }
        }
    }
}
