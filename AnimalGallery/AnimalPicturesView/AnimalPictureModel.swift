//
//  AnimalPictureModel.swift
//  AnimalGallery
//
//  Created by Jayant Badlani on 14/08/24.
//

import Foundation

// MARK: - AnimalPictureModel
struct AnimalPictureModel: Codable {
    let page, perPage: Int?
    let photos: [Photo]?
    let totalResults: Int?
    let nextPage: String?
}

// MARK: - Photo
struct Photo: Codable {
    let id, width, height: Int?
    let url: String?
    let photographer: String?
    let photographerURL: String?
    let photographerID: Int?
    let avgColor: String?
    let src: Src?
    let liked: Bool?
    let alt: String?
}

// MARK: - Src
struct Src: Codable {
    let original, large2X, large, medium: String?
    let small, portrait, landscape, tiny: String?
}
