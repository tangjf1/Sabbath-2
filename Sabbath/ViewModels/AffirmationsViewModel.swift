//
//  AffirmationsViewModel.swift
//  Sabbath
//
//  Created by Jasmine on 4/9/23.
//

import Foundation

@MainActor
class AffirmationsViewModel: ObservableObject {
    private struct Returned: Codable {
        var affirmation: String
    }
    
    let urlString = "https://www.affirmations.dev/"
    
    @Published var isLoading = false
    
    func getAffirmation() async -> String {
        print("🕸 We are accessing the url \(urlString)")
        isLoading = true
        
        // convert urlString to a special URL type
        guard let url = URL(string: urlString) else {
            print("😡 ERROR: Could not create a URL from \(urlString)")
            isLoading = false
            return ""
        }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            // Try to decode JSON into our own data structure
            guard let affirmReturned = try? JSONDecoder().decode(Returned.self, from: data)
            else {
                print("😡 JSON ERROR: Could not decode returned JSON data")
                isLoading = false
                return ""
            }
            let affirmation = affirmReturned.affirmation
            isLoading = false
            return affirmation
            
        } catch {
            print("😡 ERROR: Could not use URL at \(urlString) to get data and response ")
            isLoading = false
            return ""
        }
    }
}
    
