//
//  AnimalType.swift
//  AnimalGallery
//
//  Created by Jayant Badlani on 15/08/24.
//

import Foundation

/// Represents different types of animals.
enum AnimalType: String, CaseIterable, Identifiable {
   
    case elephant = "Elephant"
    case lion = "Lion"
    case fox = "Fox"
    case dog = "Dog"
    case shark = "Shark"
    case turtle = "Turtle"
    case whale = "Whale"
    case penguin = "Penguin"

    /// Unique identifier for each animal type.
    var id: String { rawValue }
}

