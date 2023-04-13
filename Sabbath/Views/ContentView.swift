//
//  ContentView.swift
//  Sabbath
//
//  Created by Jasmine on 4/4/23.
//
import SwiftUI
import Firebase
import FirebaseFirestore
import FirebaseFirestoreSwift

struct ContentView: View {
    @FirestoreQuery(collectionPath: "users") var users: [User]
    // only time user can see this view without being logged in is during previewProvider -> use test user for data
    @FirestoreQuery(collectionPath: "users/\(Auth.auth().currentUser?.uid ?? "tGeWm6jBzXOz0kxnuBLtl9dd3KP2")/sabbaths") var sabbaths: [SabbathEvent]
    @Environment(\.dismiss) private var dismiss
    @State var selectedDate = Date()
    @State private var showEventSheet = false
    
    var user: User {
        return users.first(where: {$0.email == Auth.auth().currentUser?.email ?? "test1@gmail.com"}) ?? User(id: "tGeWm6jBzXOz0kxnuBLtl9dd3KP2")
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                CalendarMonthView(selectedDate: $selectedDate)
                    .padding()
                
                if selectedDate.getDayOfWeek() != user.sabbath {
                    Text("Schedule for \(selectedDate.formatted(date: .abbreviated, time: .omitted))")
                    ScheduleView(selectedDate: $selectedDate)
                } else {
                    List {
                        NavigationLink {
                            SabbathView(date: selectedDate, sabbathEvent: getSabbath() )
                        } label: {
                            VStack {
                                Text("Sabbath on \(selectedDate.formatted(date: .abbreviated, time: .omitted))")
                                Image(selectedDate.getDayOfMonth())
                                    .resizable()
                                    .scaledToFit()
                                .cornerRadius(8)                            }
                        }
                        .listRowSeparator(.hidden)
                    }.listStyle(.plain)
                }
            }
            .sheet(isPresented: $showEventSheet) {
                EventDetailView(user: user, event: Event(startDate: selectedDate, endDate: (selectedDate + (60*60))))
            }
            .toolbar {
                if selectedDate.getDayOfWeek() != user.sabbath {
                    ToolbarItemGroup(placement: .bottomBar) {
                        Button("Add Item to Schedule") {
                            showEventSheet.toggle()
                        }
                        .buttonStyle(.bordered)
                    }
                }
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    HStack {
                        Text("Hello")
                        Text(user.firstName)
                            .italic()
                    }
                    .font(.callout)
                    NavigationLink{
                        UserSetUpView(user: user)
                    } label: {
                        Image(systemName: "person.crop.square")
                    }
                }
            }
        }
    }
    func getSabbath() -> SabbathEvent {
        let returned = sabbaths.first(where: {$0.id == selectedDate.getFullDate()}) ?? SabbathEvent(date: selectedDate.getFullDate())
        return returned
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
