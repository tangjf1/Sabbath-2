//
//  EventViewModel.swift
//  Sabbath
//
//  Created by Jasmine on 4/7/23.
//

import Foundation
import FirebaseFirestore

class EventViewModel: ObservableObject {
    @Published var event = Event()
    
    func saveEvent(user: User, event: Event, eventCollection: String) async -> Bool {
        let db = Firestore.firestore()
        
        
        guard let userID = user.id else {
            print("😡 ERROR: user.id = nil")
            return false
        }
        let collectionString = "users/\(userID)/\(event.startDate.getFullDate())"
        
        if event.id != nil { // event must already exist, so delete old event first, then save new event
            let _ = await deleteEvent(user: user, event: event, eventCollection: eventCollection)
        }
        do {
            let _ = try await db.collection(collectionString).addDocument(data: event.dictionary)
            print("😎 Data added successfully!")
            return true
        } catch {
            print("😡 ERROR: could not create new user in 'users' \(error.localizedDescription)")
            return false
        }
    }
    
    func deleteEvent(user: User, event: Event, eventCollection: String) async -> Bool {
        let db = Firestore.firestore()
        guard let userID = user.id, let eventID = event.id else {
            print("😡 ERROR: user.id = \(user.id ?? "nil"), event.id = \(event.id ?? "nil")")
            return false
        }
        // event must already exist, so delete
        do {
            let _ = try await db.collection("users").document(userID).collection(eventCollection).document(eventID).delete()
            print("🗑 Document deleted successfully!")
            return true
        } catch {
            print("😡 ERROR: Could not delete data in event \(error.localizedDescription)")
            return false
        }
    }
}

