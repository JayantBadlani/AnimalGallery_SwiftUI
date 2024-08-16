//
//  AnimalListViewModelTests.swift
//  AnimalGalleryTests
//
//  Created by Jayant Badlani on 15/08/24.
//

import XCTest
@testable import AnimalGallery

class AnimalListViewModelTests: XCTestCase {

    var viewModel: AnimalListViewModel!

    override func setUp() {
        super.setUp()
        viewModel = AnimalListViewModel()
    }

    override func tearDown() {
        viewModel = nil
        super.tearDown()
    }

    func testLoadAnimals() {
        viewModel.loadAnimals()
        XCTAssertEqual(viewModel.animals, ["Elephant", "Lion", "Fox", "Dog", "Shark", "Turtle", "Whale", "Penguin"])
    }
    
}
