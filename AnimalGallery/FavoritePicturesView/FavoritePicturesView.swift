//
//  FavoritePicturesView.swift
//  AnimalGallery
//
//  Created by Jayant Badlani on 15/08/24.
//

import SwiftUI
import SDWebImageSwiftUI

struct FavoritePicturesView: View {
    
    @StateObject private var viewModel = FavoritePicturesViewModel()
    @State private var selectedAnimal: String?
    @State private var showErrorAlert = false
    
    var body: some View {
        VStack(spacing: 15) {
            if viewModel.filteredImages.isEmpty {
                noFavoritesView
            } else {
                filterPicker
                favoriteImagesList
            }
        }
        .navigationTitle("Favorite Animals")
        .onAppear {
            viewModel.loadFavorites()
            viewModel.loadAnimals()
        }
        .alert(isPresented: $showErrorAlert, content: {
            Alert(
                title: Text("Error"),
                message: Text(viewModel.errorMessage ?? "Something went wrong"),
                dismissButton: .default(Text("OK"))
            )
        })
        .onChange(of: viewModel.errorMessage) { _ in
            showErrorAlert = viewModel.errorMessage != nil
        }
    }
    
    /// View shown when no favorite animals are found.
    private var noFavoritesView: some View {
        Text("No favorite animals found.")
            .font(.title2)
            .foregroundColor(.gray)
            .padding()
    }
    
    /// Picker for filtering favorite images by animal type.
    private var filterPicker: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 15) {
                FilterOptionView(title: "All", isSelected: selectedAnimal == nil) {
                    selectedAnimal = nil
                    viewModel.filterFavorites(by: nil)
                }
                
                ForEach(viewModel.animals, id: \.self) { animal in
                    FilterOptionView(title: animal, isSelected: selectedAnimal == animal) {
                        selectedAnimal = animal
                        viewModel.filterFavorites(by: animal)
                    }
                }
            }
            .padding(.top, 5)
            .padding(.horizontal)
            .padding(.bottom)
        }
    }
    
    /// List of favorite images displayed with pagination.
    private var favoriteImagesList: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(viewModel.filteredImages, id: \.self) { favorite in
                    favoriteImageRow(favorite)
                }
                
                if viewModel.hasMorePages {
                    ProgressView()
                        .onAppear {
                            viewModel.fetchNextPage()
                        }
                }
            }
            .padding(.horizontal)
        }
    }
    
    /// Row displaying a single favorite image and its details.
    private func favoriteImageRow(_ favorite: FavoriteImage) -> some View {
        HStack {
            WebImage(url: URL(string: favorite.url ?? ""))
                .resizable()
                .scaledToFill()
                .frame(width: imageSize.width, height: imageSize.height)
                .clipped()
                .cornerRadius(10)
            
            VStack(alignment: .leading) {
                Text(favorite.animalName ?? "Unknown")
                    .font(.title2)
                Spacer()
            }
            .padding()
            
            Spacer()
        }
        .shadow(radius: 10)
    }
    
    /// Computes the image size based on the device type (iPhone or iPad).
    private var imageSize: CGSize {
        if UIDevice.current.userInterfaceIdiom == .pad {
            return CGSize(width: 200, height: 200)
        } else {
            return CGSize(width: 100, height: 100)
        }
    }
}

/// View for filter options in `FavoritePicturesView`.
struct FilterOptionView: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.headline)
                .fontWeight(isSelected ? .bold : .regular)
                .padding()
                .background(isSelected ? Color.black : Color.gray.opacity(0.2))
                .foregroundColor(isSelected ? .white : .black)
                .cornerRadius(8)
                .frame(height: 40)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Preview
struct FavoritePicturesView_Previews: PreviewProvider {
    static var previews: some View {
        FavoritePicturesView()
    }
}
