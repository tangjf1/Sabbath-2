//
//  EventViewModel.swift
//  Sabbath
//
//  Created by Jasmine on 4/7/23.
//

import Foundation
import FirebaseFirestore

@MainActor
class EventViewModel: ObservableObject {
    @Published var isLoading = false
    
    func saveEvent(user: User, event: Event, eventCollection: String) async -> Bool {
        let db = Firestore.firestore()
        isLoading = true
        
        guard let userID = user.id else {
            print("😡 ERROR: user.id = nil")
            isLoading = false
            return false
        }
        let collectionString = "users/\(userID)/\(event.startDate.getFullDate())"
        
        if event.id != nil { // event must already exist, so delete old event first, then save new event
            let _ = await deleteEvent(user: user, event: event, eventCollection: eventCollection)
        }
        do {
            let _ = try await db.collection(collectionString).addDocument(data: event.dictionary)
            print("😎 Data added successfully!")
            isLoading = false
            return true
        } catch {
            print("😡 ERROR: could not create new user in 'users' \(error.localizedDescription)")
            isLoading = false
            return false
        }
    }
    
    func deleteEvent(user: User, event: Event, eventCollection: String) async -> Bool {
        let db = Firestore.firestore()
        isLoading = true
        guard let userID = user.id, let eventID = event.id else {
            print("😡 ERROR: user.id = \(user.id ?? "nil"), event.id = \(event.id ?? "nil")")
            isLoading = false
            return false
        }
        // event must already exist, so delete
        do {
            let _ = try await db.collection("users").document(userID).collection(eventCollection).document(eventID).delete()
            print("🗑 Document deleted successfully!")
            isLoading = false
            return true
        } catch {
            print("😡 ERROR: Could not delete data in event \(error.localizedDescription)")
            isLoading = false
            return false
        }
    }
}

