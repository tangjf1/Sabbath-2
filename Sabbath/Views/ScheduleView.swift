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
    @State var user: User
    @Binding var selectedDate: Date
    @FirestoreQuery(collectionPath: "users/\(Auth.auth().currentUser?.uid ?? "")/\(Date().getFullDate())") var events: [Event]
    
    var body: some View {
        VStack {
            Text("Schedule for \(selectedDate.formatted(date: .abbreviated, time: .omitted))")
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
        .onChange(of: selectedDate) { newValue in
            $events.path = "users/\(Auth.auth().currentUser?.uid ?? "")/\(selectedDate.getFullDate())"
        }
    }
}

struct ScheduleView_Previews: PreviewProvider {
    static var previews: some View {
        ScheduleView(user: User(), selectedDate: .constant(Date()))
    }
}
