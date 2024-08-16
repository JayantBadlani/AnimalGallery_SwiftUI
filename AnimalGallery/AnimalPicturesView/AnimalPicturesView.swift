//
//  AnimalPicturesView.swift
//  AnimalGallery
//
//  Created by Jayant Badlani on 14/08/24.
//

import SwiftUI
import SDWebImageSwiftUI


struct AnimalPicturesView: View {
    
    @StateObject private var viewModel: AnimalPicturesViewModel
    @State private var isLoading = true
    @State private var showErrorAlert = false
    
    init(animal: AnimalType) {
        _viewModel = StateObject(wrappedValue: AnimalPicturesViewModel(selectedAnimal: animal))
    }
    
    var body: some View {
        VStack {
            if isLoading {
                loadingView
            } else {
                contentView
            }
        }
        .navigationTitle(viewModel.selectedAnimal.rawValue.capitalized)
        .onAppear {
            viewModel.fetchAnimalDetails {
                isLoading = false
            }
        }
        .alert(isPresented: $showErrorAlert) {
            Alert(
                title: Text("Error"),
                message: Text(viewModel.errorMessage ?? "Something went wrong"),
                dismissButton: .default(Text("OK"))
            )
        }
        .onChange(of: viewModel.errorMessage) { _ in
            showErrorAlert = viewModel.errorMessage != nil
        }
    }
    
    /// View displayed while data is loading.
    private var loadingView: some View {
        VStack(spacing: 10) {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle())
            Text("Loading...")
                .font(.headline)
                .foregroundColor(.gray)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    /// Main content view displaying animal details and images.
    private var contentView: some View {
        ScrollView {
            VStack(spacing: 16) {
                if let animalDetails = viewModel.animalDetails {
                    AnimalDetailsView(animalDetails: animalDetails)
                        .padding()
                }
                
                LazyVStack(spacing: 25) {
                    ForEach(viewModel.images.indices, id: \.self) { index in
                        AnimalImageRow(imageURL: viewModel.images[index], isFavorite: viewModel.isFavorite(imageURL:)) {
                            viewModel.toggleFavorite(imageURL: viewModel.images[index])
                        }
                        .onAppear {
                            if index == viewModel.images.count - 1 {
                                viewModel.fetchNextPage()
                            }
                        }
                    }
                    .padding(.horizontal)
                }
            }
            .padding(.top)
        }
    }
}

/// View displaying details about an animal.
struct AnimalDetailsView: View {
    let animalDetails: AnimalDetailsModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            AnimalDetailRow(imageName: "leaf", title: "Scientific Name", detail: animalDetails.taxonomy?.scientificName)
            AnimalDetailRow(imageName: "globe", title: "Habitat", detail: animalDetails.characteristics?.habitat)
            AnimalDetailRow(imageName: "clock", title: "Lifespan", detail: animalDetails.characteristics?.lifespan)
        }
    }
}

/// View displaying a single detail row with an icon and text.
struct AnimalDetailRow: View {
    let imageName: String
    let title: String
    let detail: String?
    
    var body: some View {
        HStack(alignment: .top) {
            Image(systemName: imageName)
                .foregroundColor(.accentColor)
            Text("\(title):")
                .font(.headline)
                .bold()
            Text(detail?.isEmpty == false ? detail! : "N/A")
                .font(.subheadline)
                .foregroundColor(.primary)
            Spacer()
        }
    }
}

/// View displaying an image with a favorite button overlay.
struct AnimalImageRow: View {
    let imageURL: String
    let isFavorite: (String) -> Bool
    let toggleFavorite: () -> Void
    
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            WebImage(url: URL(string: imageURL)) { image in
                image.resizable()
                    .scaledToFill()
            } placeholder: {
                placeholderImage
            }
            .frame(height: 200)
            .clipped()
            .cornerRadius(10)
            .shadow(radius: 10)
            .overlay(
                favoriteButton
                    .padding(8)
                , alignment: .topTrailing
            )
        }
    }
    
    /// placeholderImage
    private var placeholderImage: some View {
        Rectangle()
            .foregroundColor(Color.gray.opacity(0.2))
            .frame(height: 200)
            .cornerRadius(10)
            .overlay(
                Image(systemName: "photo")
                    .resizable()
                    .scaledToFit()
                    .padding(20)
            )
    }
    
    /// Determines image height based on device size class.
    private var imageHeight: CGFloat {
        horizontalSizeClass == .compact ? 200 : 500
    }
    
    /// Button to mark the image as favorite.
    private var favoriteButton: some View {
        Button(action: toggleFavorite) {
            Image(systemName: isFavorite(imageURL) ? "heart.fill" : "heart")
                .foregroundColor(isFavorite(imageURL) ? .red : .white)
                .padding()
                .background(Color.black.opacity(0.7))
                .clipShape(Circle())
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Preview
struct AnimalPicturesView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            AnimalPicturesView(animal: .dog)
        }
    }
}
