//
//  AnimalListView.swift
//  AnimalGallery
//
//  Created by Jayant Badlani on 14/08/24.
//

import SwiftUI


struct AnimalListView: View {
    
    @StateObject private var viewModel = AnimalListViewModel()

    var body: some View {
        NavigationView {
            List(AnimalType.allCases, id: \.self) { animalType in
                AnimalRow(animalType: animalType)
            }
            .navigationTitle("Animal Gallery")
            .navigationBarItems(trailing: favoritesButton)
        }
        .navigationViewStyle(StackNavigationViewStyle()) // Ensure full screen on iPad
        .onAppear(perform: {
            viewModel.loadAnimals()
        })
    }
    
    /// Button for navigating to the FavoritePicturesView.
    private var favoritesButton: some View {
        NavigationLink(destination: FavoritePicturesView()) {
            HStack {
                Image(systemName: "heart.fill")
                    .foregroundColor(.red)
                Text("Favorites")
                    .foregroundColor(.black)
            }
        }
    }
}

/// Displays a row with an animal type and navigation to its pictures.
struct AnimalRow: View {
    let animalType: AnimalType

    var body: some View {
        NavigationLink(destination: AnimalPicturesView(animal: animalType)) {
            HStack {
                Image(systemName: "pawprint.fill")
                    .foregroundColor(.accentColor)
                    .shadow(radius: 10)
                Text(animalType.rawValue.capitalized)
                    .font(.headline)
                    .padding(.vertical, 8)
            }
        }
    }
}


// MARK: - Preview
/// Provides previews for AnimalListView.
struct AnimalListView_Previews: PreviewProvider {
    static var previews: some View {
        AnimalListView()
    }
}
