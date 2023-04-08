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
    
    func saveEvent(user: User, event: Event) async -> Bool {
        let db = Firestore.firestore()
        
        
        guard let userID = user.id else {
            print("😡 ERROR: user.id = nil")
            return false
        }
        let collectionString = "users/\(userID)/\(event.startDate.getFullDate())"
        
        if let id = event.id { // event must already exist, so save
            do {
                try await db.collection(collectionString).document(id).setData(event.dictionary)
                print("😎 Data updated successfully!")
                return true
            } catch {
                print("😡 ERROR: Could not load data in users \(error.localizedDescription)")
                return false
            }
        } else { // no id? Then it's a new event to add
            do {
                let _ = try await db.collection(collectionString).addDocument(data: event.dictionary)
                print("😎 Data added successfully!")
                return true
            } catch {
                print("😡 ERROR: could not create new user in 'users' \(error.localizedDescription)")
                return false
            }
        }
    }
    
    func deleteEvent(user: User, event: Event) async -> Bool {
        let db = Firestore.firestore()
        guard let userID = user.id, let eventID = event.id else {
            print("😡 ERROR: user.id = \(user.id ?? "nil"), event.id = \(event.id ?? "nil")")
            return false
        }
        // event must already exist, so delete
        do {
            let _ = try await db.collection("users").document(userID).collection("events").document(eventID).delete()
            print("🗑 Document deleted successfully!")
            return true
        } catch {
            print("😡 ERROR: Could not delete data in event \(error.localizedDescription)")
            return false
        }
    }
}

