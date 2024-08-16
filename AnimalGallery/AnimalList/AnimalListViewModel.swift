//
//  AnimalListViewModel.swift
//  AnimalGallery
//
//  Created by Jayant Badlani on 14/08/24.
//

import Foundation

class AnimalListViewModel: ObservableObject {
    
    @Published var animals: [String]?

    func loadAnimals() {
        animals = AnimalType.allCases.map { $0.rawValue }
    }
}

