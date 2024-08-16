# AnimalGallery_SwiftUI
## AnimalGallery_SwiftUI is an iOS application that allows users to browse a list of animals, view their pictures, and manage their favorites. It uses the API-NINJAS for animal details and the API-Pexels for fetching images. Core Data is used to store and manage favorite pictures.

## Features
### List of Animals Screen
List of Animals: Displays a list of specific animals (Elephant, Lion, Fox, Dog, Shark, Turtle, Whale, Penguin).
Navigation to Animal Pictures: Tap on an animal to navigate to the Animal Pictures screen.
Favorites Button: Navigate to the Favorite Pictures screen.

### Animal Pictures Screen
Display Pictures: Shows all available pictures for the selected animal.
Like/Unlike Functionality: Allows users to like/unlike images.
Fetch Images: Uses the Pexels API to retrieve images.
Store Liked Images: Saves liked images as favorites in Core Data.

### Favorite Pictures Screen
Display Favorite Images: Shows all images that users have liked.
Show Animal Name: Displays which animal each image belongs to.
Filter by Animal: Filter favorite images by animal.


## Core Data Integration
Core Data Setup: A centralized Core Data Manager handles saving, fetching, and deleting favorite images.
Fetch/Save/Remove: Manages Core Data operations for favorite images.

## API Integration
API-NINJAS for Animal Details: Fetches animal details from the API-NINJAS.
Pexels API for Images: Retrieves animal images from the Pexels API.

## UI/UX
Responsive Design: Ensures proper layout for both iPhone and iPad.
User Feedback: Displays loading indicators, error alerts, and other feedback.
Navigation: Smooth transitions between screens.

## Error Handling
Network Errors: Handled with appropriate error messages to the user.
Core Data Errors: Managed within the Core Data Manager.

## Refactoring & Code Quality
Code Refactoring: Clean, modular code following best practices.
Comments & Documentation: Well-commented important sections of the code.
