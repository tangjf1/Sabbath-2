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
import FirebaseStorage
import UIKit

@MainActor
class UserViewModel: ObservableObject {
    @Published var isLoadingMain = false
    @Published var isLoadingPhoto = false
    

    func saveUser(user: User) async -> String? {
        let db = Firestore.firestore()
        isLoadingMain = true
        let userID = user.id ?? Auth.auth().currentUser?.uid ?? ""
        do {
            let _ = try await db.collection("users").document(userID).setData(user.dictionary)
            print("😎 Data added successfully!")
            isLoadingMain = false
            return userID
        } catch {
            print("😡 ERROR: could not save new user in 'users' \(error.localizedDescription)")
            isLoadingMain = false
            return nil
        }
    }
    
    func saveImage(id: String, image: UIImage) async {
        isLoadingPhoto = true
        let storage = Storage.storage()
        let storageRef = storage.reference().child("\(id)/image.jpg")
        
        let resizedImage = image.jpegData(compressionQuality: 0.2)
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpg"
        
        if let resizedImage = resizedImage {
            do {
                let metadata = try await storageRef.putDataAsync(resizedImage)
                print("Metadata: ", metadata)
                print("📸 Image Saved!")
                isLoadingPhoto = false
            } catch {
                print("😡 ERROR: uploading image to FirebaseStorage \(error.localizedDescription)")
                isLoadingPhoto = false
            }
        }
        isLoadingPhoto = false
    }
    
    func getImageURL(id: String) async -> URL? {
        isLoadingPhoto = true
        let storage = Storage.storage()
        let storageRef = storage.reference().child("\(id)/image.jpg")
        
        do {
            let url = try await storageRef.downloadURL()
            isLoadingPhoto = false
            return url
        } catch {
            isLoadingPhoto = false
            return nil
        }
    }
}
