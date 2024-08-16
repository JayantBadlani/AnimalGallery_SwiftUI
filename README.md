# AnimalGallery_SwiftUI
## AnimalGallery_SwiftUI is an iOS application that allows users to browse a list of animals, view their pictures, and manage their favorites. It uses the API-NINJAS for animal details and the API-Pexels for fetching images. Core Data is used to store and manage favorite pictures.

<img width="250" alt="Screenshot 2024-08-16 at 3 47 54 PM" src="https://github.com/user-attachments/assets/8c2d40ff-cdb2-4227-b771-068d86cb4c11">
<img width="250" alt="Screenshot 2024-08-16 at 3 44 29 PM" src="https://github.com/user-attachments/assets/88a14fc4-73cd-4fe4-8729-664b643c5b0f">
<img width="250" alt="Screenshot 2024-08-16 at 3 45 19 PM" src="https://github.com/user-attachments/assets/f48fd3df-0e9c-43ea-8d66-82281b91cdfa">

## Features
### 1. List of Animals Screen
**List of Animals:** Displays a list of specific animals (Elephant, Lion, Fox, Dog, Shark, Turtle, Whale, Penguin).
**Navigation to Animal Pictures:** Tap on an animal to navigate to the Animal Pictures screen.
**Favorites Button:** Navigate to the Favorite Pictures screen.

### 2. Animal Pictures Screen
**Display Pictures:** Shows all available pictures for the selected animal.
**Like/Unlike Functionality:** Allows users to like/unlike images.
**Fetch Images:** Uses the Pexels API to retrieve images.
**Store Liked Images:** Saves liked images as favorites in Core Data.

### 3. Favorite Pictures Screen
**Display Favorite Images:** Shows all images that users have liked.
**Show Animal Name:** Displays which animal each image belongs to.
**Filter by Animal:** Filter favorite images by animal.


## Architecture & Design
**MVVM:** The app follows the MVVM (Model-View-ViewModel) architecture pattern to separate concerns and improve maintainability.

**SwiftUI:** The user interface is built using SwiftUI, providing a modern and declarative approach to UI development.

**Code Structure:** The code is organized into separate modules for networking, data management, and UI components.

**Responsive Design:** Ensures proper layout for both iPhone and iPad.

**User Feedback:** Displays loading indicators, error alerts, and other feedback.

**Navigation:** Smooth transitions between screens.

## DataBase Integration
**Core Data Setup:** A centralized Core Data Manager handles saving, fetching, and deleting favorite images.
**Fetch/Save/Remove:** Manages Core Data operations for favorite images.

## API Integration
**API-NINJAS for Animal Details:** Fetches animal details from the API-NINJAS.
**Pexels API for Images:** Retrieves animal images from the Pexels API.

## Image Caching
**SDWebImageSwiftUI:** Utilizes SDWebImageSwiftUI using Swift Package Manager for efficient image caching and loading.

## Error Handling
**Network Errors:** Handled with appropriate error messages to the user.
**Core Data Errors:** Managed within the Core Data Manager.

### Clean, modular code following best practices and well-commented important sections of the code.
