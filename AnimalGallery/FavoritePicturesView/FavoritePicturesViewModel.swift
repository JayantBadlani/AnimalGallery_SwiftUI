//
//  FavoritePicturesViewModel.swift
//  AnimalGallery
//
//  Created by Jayant Badlani on 15/08/24.
//

import Foundation

class FavoritePicturesViewModel: ObservableObject {
    
    @Published var favoriteImages: [FavoriteImage] = []
    @Published var filteredImages: [FavoriteImage] = []
    @Published var animals: [String] = []
    @Published var hasMorePages: Bool = true
    @Published var errorMessage: String?
    
    var coreDataManager: CoreDataManaging
    private var currentPage = 1
    var getCurrentPage: Int {
        return currentPage
    }
    private let itemsPerPage = 15
    private var selectedAnimal: String?
    
    init(coreDataManager: CoreDataManaging = CoreDataManager()) {
        self.coreDataManager = coreDataManager
    }
    
    /// Loads the list of favorite images from Core Data.
    func loadFavorites() {
        fetchFavorites()
    }
    
    /// Loads the list of distinct animal names from Core Data.
    func loadAnimals() {
        coreDataManager.fetchFavorites(animalName: nil) { [weak self] result in
            switch result {
            case .success(let favorites):
                let distinctAnimals = Set(favorites.compactMap { $0.animalName })
                self?.animals = Array(distinctAnimals).sorted()
            case .failure(let error):
                self?.errorMessage = "Failed to load animals: \(error.localizedDescription)"
            }
        }
    }
    
    /// Fetches the list of favorite images from Core Data with pagination.
    func fetchFavorites() {
        coreDataManager.fetchFavorites(animalName: selectedAnimal) { [weak self] result in
            switch result {
            case .success(let favorites):
                self?.paginateFavorites(favorites)
            case .failure(let error):
                self?.errorMessage = "Failed to fetch favorites: \(error.localizedDescription)"
            }
        }
    }
    
    /// Fetches the next page of favorite images if available.
    func fetchNextPage() {
        if hasMorePages {
            currentPage += 1
            fetchFavorites()
        }
    }
    
    /// Resets pagination and fetches the initial set of favorite images.
    func resetPagination() {
        currentPage = 1
        filteredImages.removeAll()
        fetchFavorites()
    }
    
    /// Filters favorite images based on the selected animal.
    func filterFavorites(by animalName: String?) {
        selectedAnimal = animalName
        resetPagination()
    }
    
    /// Paginates the list of favorite images.
    private func paginateFavorites(_ favorites: [FavoriteImage]) {
        let startIndex = (currentPage - 1) * itemsPerPage
        let endIndex = min(startIndex + itemsPerPage, favorites.count)
        let paginatedFavorites = Array(favorites[startIndex..<endIndex])
        
        if currentPage == 1 {
            filteredImages = paginatedFavorites
        } else {
            filteredImages.append(contentsOf: paginatedFavorites)
        }
        
        hasMorePages = endIndex < favorites.count
    }
}
