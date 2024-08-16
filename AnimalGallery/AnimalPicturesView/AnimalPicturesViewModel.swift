//
//  AnimalPicturesViewModel.swift
//  AnimalGallery
//
//  Created by Jayant Badlani on 15/08/24.
//

import Foundation


class AnimalPicturesViewModel: ObservableObject {
    
    @Published var images: [String] = []
    @Published var animalDetails: AnimalDetailsModel?
    @Published var favoriteImages: Set<String> = []
    @Published var errorMessage: String? // Error message to be shown
    
    var networkManager: NetworkManaging
    var coreDataManager: CoreDataManaging
    var selectedAnimal: AnimalType
    private var currentPage = 1
    private var isFetching = false
    private var hasMorePages = true
    
    init(selectedAnimal: AnimalType, networkManager: NetworkManaging = NetworkManager(), coreDataManager: CoreDataManaging = CoreDataManager()) {
        self.selectedAnimal = selectedAnimal
        self.networkManager = networkManager
        self.coreDataManager = coreDataManager
        loadFavorites()
    }
    
    // Fetches details about the selected animal.
    func fetchAnimalDetails(completion: @escaping () -> Void) {
        networkManager.fetchAnimalDetails(name: selectedAnimal.rawValue) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let animal):
                    self?.animalDetails = animal
                    self?.resetPagination()
                case .failure(let error):
                    self?.errorMessage = "Error fetching animal details: \(error.localizedDescription)"
                }
                completion()
            }
        }
    }
    
    // Fetches images of the selected animal.
    func fetchImages(completion: @escaping () -> Void) {
        guard !isFetching, hasMorePages else { return }
        isFetching = true
        
        networkManager.fetchImages(for: selectedAnimal.rawValue, page: currentPage) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let animalPictureModel):
                    if let newImages = animalPictureModel.photos?.compactMap({ $0.src?.large }) {
                        self?.images.append(contentsOf: newImages)
                        self?.currentPage += 1
                        self?.hasMorePages = animalPictureModel.photos?.count ?? 0 > 0
                    }
                case .failure(let error):
                    self?.errorMessage = "Error fetching images: \(error.localizedDescription)"
                }
                self?.isFetching = false
                completion()
            }
        }
    }
    
    // Fetches the next page of images.
    func fetchNextPage() {
        fetchImages { }
    }
    
    // Resets pagination and fetches the first page of images.
    func resetPagination() {
        currentPage = 1
        images.removeAll()
        hasMorePages = true
        fetchImages { }
    }
    
    // Toggles the favorite status of an image.
    func toggleFavorite(imageURL: String) {
        if favoriteImages.contains(imageURL) {
            favoriteImages.remove(imageURL)
            coreDataManager.removeFavorite(imageURL: imageURL) { [weak self] error in
                if let error = error {
                    self?.errorMessage = "Failed to remove favorite: \(error.localizedDescription)"
                    self?.favoriteImages.insert(imageURL) // Rollback the change
                }
            }
        } else {
            favoriteImages.insert(imageURL)
            coreDataManager.addFavorite(imageURL: imageURL, animalName: selectedAnimal.rawValue) { [weak self] error in
                if let error = error {
                    self?.errorMessage = "Failed to add favorite: \(error.localizedDescription)"
                    self?.favoriteImages.remove(imageURL) // Rollback the change
                }
            }
        }
    }
    
    // Checks if an image is marked as favorite.
    func isFavorite(imageURL: String) -> Bool {
        return favoriteImages.contains(imageURL)
    }
    
    // Loads favorite images from Core Data.
    func loadFavorites() {
        coreDataManager.fetchFavorites(animalName: selectedAnimal.rawValue) { [weak self] result in
            switch result {
            case .success(let favorites):
                self?.favoriteImages = Set(favorites.map { $0.url ?? "" })
            case .failure(let error):
                self?.errorMessage = "Failed to load favorites: \(error.localizedDescription)"
            }
        }
    }
}
