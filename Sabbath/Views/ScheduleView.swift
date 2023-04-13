//
//  ScheduleView.swift
//  Sabbath
//
//  Created by Jasmine on 4/8/23.
//

import SwiftUI
import Firebase
import FirebaseFirestore
import FirebaseFirestoreSwift

struct ScheduleView: View {
    @FirestoreQuery(collectionPath: "users") var users: [User]
    var user: User {
        // only time user can see this view without being logged in is during previewProvider -> use test user for data
        return users.first(where: {$0.email == Auth.auth().currentUser?.email ?? "tGeWm6jBzXOz0kxnuBLtl9dd3KP2"}) ?? User()
    }
    @Binding var selectedDate: Date
    // only time user can see this view without being logged in is during previewProvider -> use test user for data
    @FirestoreQuery(collectionPath: "users/\(Auth.auth().currentUser?.uid ?? "tGeWm6jBzXOz0kxnuBLtl9dd3KP2")/\(Date().getFullDate())") var events: [Event]
    
    var body: some View {
        VStack {
            List {
                ForEach(events.sorted{ $0.startDate < $1.startDate }, id: \.id) { event in
                    NavigationLink {
                        EventDetailView(user: user, event: event)
                    } label: {
                        Text("\(event.startDate.formatted(date: .omitted, time: .shortened)) - \(event.title)")
                    }
                }
            }
            .font(.callout)
            .listStyle(.plain)
        }
        .onAppear {
            $events.path = "users/\(Auth.auth().currentUser?.uid ?? "tGeWm6jBzXOz0kxnuBLtl9dd3KP2")/\(selectedDate.getFullDate())"
        }
        .onChange(of: selectedDate) { _ in
            $events.path = "users/\(Auth.auth().currentUser?.uid ?? "tGeWm6jBzXOz0kxnuBLtl9dd3KP2")/\(selectedDate.getFullDate())"
        }
    }
}

struct ScheduleView_Previews: PreviewProvider {
    static var previews: some View {
        ScheduleView(selectedDate: .constant(Date()))
    }
}
