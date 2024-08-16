//
//  NetworkManager.swift
//  AnimalGallery
//
//  Created by Jayant Badlani on 14/08/24.
//

import Foundation

// MARK: - NetworkManaging Protocol
protocol NetworkManaging {
    func fetchAnimalDetails(name: String, completion: @escaping (Result<AnimalDetailsModel, Error>) -> Void)
    func fetchImages(for query: String, page: Int, completion: @escaping (Result<AnimalPictureModel, Error>) -> Void)
}


// MARK: - NetworkManager
class NetworkManager: NetworkManaging {
    
    // MARK: - API Endpoints and Keys
    private let animalsAPIURL = "https://api.api-ninjas.com/v1/animals"
    private let animalsAPIKey = ProcessInfo.processInfo.environment["ANIMALS_API_KEY"] ?? ""
    
    private let pexelsAPIURL = "https://api.pexels.com/v1/search"
    private let pexelsAPIKey = ProcessInfo.processInfo.environment["PEXELS_API_KEY"] ?? ""
    
    
    // MARK: - Fetch Animal Details
    /// Fetches details of a specific animal from the API.
    func fetchAnimalDetails(name: String, completion: @escaping (Result<AnimalDetailsModel, Error>) -> Void) {
        
        let query = "?name=\(name)"
        guard let url = URL(string: animalsAPIURL + query) else {
            completion(.failure(NetworkError.invalidURL))
            return
        }
        
        var request = URLRequest(url: url)
        request.addValue(animalsAPIKey, forHTTPHeaderField: "X-Api-Key")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                let statusCode = (response as? HTTPURLResponse)?.statusCode ?? -1
                let error = NSError(domain: "", code: statusCode, userInfo: [NSLocalizedDescriptionKey: "Unexpected status code"])
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(NetworkError.noData))
                return
            }
            
            let responseString = String(data: data, encoding: .utf8) ?? "No data"
            debugPrint("fetchAnimalDetails Response String: \(responseString)")
            
            do {
                let animals = try JSONDecoder().decode([AnimalDetailsModel].self, from: data)
                if let animal = animals.first {
                    completion(.success(animal))
                } else {
                    completion(.failure(NetworkError.noData))
                }
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
    
    // MARK: - Fetch Images
    /// Fetches images for a given query and page from the Pexels API.
    func fetchImages(for query: String, page: Int, completion: @escaping (Result<AnimalPictureModel, Error>) -> Void) {
        
        var urlComponents = URLComponents(string: pexelsAPIURL)
        urlComponents?.queryItems = [
            URLQueryItem(name: "query", value: query),
            URLQueryItem(name: "per_page", value: "15"),
            URLQueryItem(name: "page", value: "\(page)")
        ]
        
        guard let url = urlComponents?.url else {
            completion(.failure(NetworkError.invalidURL))
            return
        }
        
        var request = URLRequest(url: url)
        request.addValue(pexelsAPIKey, forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(NetworkError.noData))
                return
            }
            
            let responseString = String(data: data, encoding: .utf8) ?? "No data"
            debugPrint("fetchImages Response String: \(responseString)")
            
            do {
                let decoder = JSONDecoder()
                let animalPictureModel = try decoder.decode(AnimalPictureModel.self, from: data)
                completion(.success(animalPictureModel))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
}

// MARK: - Network Errors
/// Enum representing possible network errors.
enum NetworkError: Error {
    case invalidURL
    case noData
}
