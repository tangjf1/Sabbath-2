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
            return true
        } catch {
            print("😡 ERROR: could not save new user in 'users' \(error.localizedDescription)")
            return false
        }
    }
}
