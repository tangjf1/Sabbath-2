//
//  SabbathViewModel.swift
//  Sabbath
//
//  Created by Jasmine on 4/10/23.
//

import Foundation
import Firebase
import FirebaseFirestore

@MainActor
class SabbathViewModel: ObservableObject {
    @Published var journalPrompts = [
        "What are 3 things you're grateful for today?",  "How can you prioritize self-care in your daily routine?",  "Why is it important to celebrate your accomplishments, big or small?",  "What is a limiting belief you hold about yourself and how can you challenge it?",  "When do you feel most like yourself?",  "How can you overcome a challenge you're currently facing?",  "What is something you're currently struggling with in terms of self-love and self-acceptance?",  "What steps can you take today to work towards a long-term goal?",  "Why is it important to let go of toxic habits or behaviors?",  "What is something you've learned recently about yourself and how can you apply it to your life?",  "What is something you're curious about and want to explore more?",  "How can you show kindness to yourself and others today?",  "What positive affirmation can you say to yourself when you need encouragement?",  "What is something you're feeling stuck on and need to work through?",  "What is a mistake you've made in the past and what have you learned from it?",  "What is a fear you have and how can you face it?",  "What is a passion or hobby you want to make more time for?",  "What is something you appreciate about your body and why?",  "What is a relationship that brings positivity and growth to your life and why?",  "What is a skill or talent you have and want to develop further?",  "What is a book or article you've read recently that has inspired you and why?",  "How can you incorporate mindfulness or meditation into your daily routine?",  "What is something you're feeling grateful for in this moment?",  "What is a way you can show yourself love and care today?",  "What is something that brings you joy and how can you incorporate more of it into your life?",  "What is a value that is important to you and how can you align your actions with it?",  "What is something you can do to challenge yourself and step out of your comfort zone?",  "How can you give back to your community or a cause you care about?",  "What is something you're currently learning and how can you apply it to your life?",  "What is a way you can practice gratitude and mindfulness before going to bed tonight?",  "What is a way you can set boundaries and protect your energy today?"
    ]

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
    
    func saveSabbathEvent(sabbathEvent: SabbathEvent) async -> Bool {
        let db = Firestore.firestore()
        isLoading = true
        
        guard let userID = Auth.auth().currentUser?.uid else {
            print("😡 ERROR: user.id = nil")
            isLoading = false
            return false
        }
        let collectionString = "users/\(userID)/sabbaths"
        let sabbathEventID = sabbathEvent.date
        
        do {
            let _ = try await db.collection(collectionString).document(sabbathEventID).setData(sabbathEvent.dictionary)
            print("😎 Data added successfully!")
            isLoading = false
            return true
        } catch {
            print("😡 ERROR: could not create new sabbathEvent in 'sabbaths' \(error.localizedDescription)")
            isLoading = false
            return false
        }
    }
}
    

