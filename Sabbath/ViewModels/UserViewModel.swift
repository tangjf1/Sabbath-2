//
//  UserViewModel.swift
//  Sabbath
//
//  Created by Jasmine on 4/5/23.
//

import Foundation
import FirebaseFirestore
import Firebase // For access to authentication and user info
import FirebaseFirestoreSwift

@MainActor
class UserViewModel: ObservableObject {
    @Published var user = User()
    @Published var users = [User]()
    
    func saveUser(user: User) async -> Bool {
        let db = Firestore.firestore()
        let userID = user.id ?? Auth.auth().currentUser?.uid ?? ""
        do {
            let _ = try await db.collection("users").document(userID).setData(user.dictionary)
            print("😎 Data added successfully!")
            Task {
                await print(getAllUsers())
            }
            return true
        } catch {
            print("😡 ERROR: could not save new user in 'users' \(error.localizedDescription)")
            return false
        }
    }
    
    func getAllUsers() async -> Bool {
        let db = Firestore.firestore()
        do {
            let querySnapshot = try await db.collection("users").getDocuments()
            print("DOCUMENTS RETRIEVED")
            for doc in querySnapshot.documents {
                print("\(doc.documentID) => \(doc.data())")
            }
            return true
        } catch {
            print("😡 ERROR: could not load users in 'users' \(error.localizedDescription)")
            return false
        }
    }
    
    func getCurrentUser() -> User {
        @FirestoreQuery(collectionPath: "users") var users: [User]
        return users.first(where: {$0.email == Auth.auth().currentUser?.email ?? "" }) ?? User()
    }
}
