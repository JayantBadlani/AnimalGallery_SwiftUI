//
//  AnimalModel.swift
//  AnimalGallery
//
//  Created by Jayant Badlani on 14/08/24.
//

import Foundation

// MARK: - AnimalModel
struct AnimalDetailsModel: Codable {
    let name: String?
    let taxonomy: Taxonomy?
    let locations: [String]?
    let characteristics: Characteristics?
}

// MARK: - Characteristics
struct Characteristics: Codable {
    let prey, nameOfYoung, groupBehavior, estimatedPopulationSize: String?
    let biggestThreat, mostDistinctiveFeature, otherNameS, gestationPeriod: String?
    let habitat, predators, diet, averageLitterSize: String?
    let lifestyle, commonName, numberOfSpecies, location: String?
    let slogan, group, color, skinType: String?
    let topSpeed, lifespan, weight, length: String?
    let ageOfSexualMaturity, ageOfWeaning, distinctiveFeature, temperament: String?
    let training, type, litterSize, height: String?
    let origin, mainPrey, favoriteFood, waterType: String?
    let optimumPhLevel, averageClutchSize: String?
}

// MARK: - Taxonomy
struct Taxonomy: Codable {
    let kingdom, phylum, taxonomyClass, order: String?
    let family, genus, scientificName: String?
}
