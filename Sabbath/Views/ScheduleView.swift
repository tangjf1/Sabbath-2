//
//  ScheduleView.swift
//  Sabbath
//
//  Created by Jasmine on 4/8/23.
//

import SwiftUI
import Foundation
import Combine
import Firebase
import FirebaseFirestore
import FirebaseFirestoreSwift

struct ScheduleView: View {
    @FirestoreQuery(collectionPath: "users") var users: [User]
    var user: User {
        return users.first(where: {$0.email == Auth.auth().currentUser?.email ?? ""}) ?? User()
    }
    @Binding var selectedDate: Date
    @FirestoreQuery(collectionPath: "users/\(Auth.auth().currentUser?.uid ?? "none")/\(Date().getFullDate())") var events: [Event]
    
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
            print("users/\(Auth.auth().currentUser?.uid ?? "none")/\(selectedDate.getFullDate())")
            $events.path = "users/\(Auth.auth().currentUser?.uid ?? "none")/\(selectedDate.getFullDate())"
            print("events: \(events)")
        }
        .onChange(of: selectedDate) { _ in
            print("users/\(Auth.auth().currentUser?.uid ?? "none")/\(selectedDate.getFullDate())")
            $events.path = "users/\(Auth.auth().currentUser?.uid ?? "none")/\(selectedDate.getFullDate())"
        }
    }
}

struct ScheduleView_Previews: PreviewProvider {
    static var previews: some View {
        ScheduleView(selectedDate: .constant(Date()))
    }
}
