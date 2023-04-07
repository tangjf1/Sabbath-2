//
//  ListUsersTest.swift
//  Sabbath
//
//  Created by Jasmine on 4/5/23.
//

import SwiftUI
import Firebase
import FirebaseFirestoreSwift

struct ListUsersTest: View {
    @FirestoreQuery(collectionPath: "users") var users: [User]
    @State var user = User()
    @State private var sheetIsPresented = false
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            List(users) { user in
                    Text("\(user.firstName), \(user.lastName)")
                        .font(.title2)
                
                
            }
            .listStyle(.plain)
            .navigationTitle("List of Users")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Sign Out") {
                        do {
                            try Auth.auth().signOut()
                            print("🪵➡️ Logout Successful!")
                            dismiss()
                        } catch {
                            print("😡 ERROR: Could not sign out!")
                        }
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        user = users.first(where: {$0.email == Auth.auth().currentUser?.email ?? ""}) ?? User()
                        print("Retrieved current user: \(user)")
                        sheetIsPresented.toggle()
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .fullScreenCover(isPresented: $sheetIsPresented) {
                NavigationStack{
                    ContentView()
                }
            }
        }
        
    }
}

struct ListUsersTest_Previews: PreviewProvider {
    static var previews: some View {
        ListUsersTest()
            .environmentObject(UserViewModel())
    }
}
