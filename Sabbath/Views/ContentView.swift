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
    @EnvironmentObject var locationManager: LocationManager
    @EnvironmentObject var weatherVM: WeatherViewModel
    @EnvironmentObject var userVM: UserViewModel
    
    @FirestoreQuery(collectionPath: "users") var users: [User]
    // only time user can see this view without being logged in is during previewProvider -> use test user for data
    @FirestoreQuery(collectionPath: "users/\(Auth.auth().currentUser?.uid ?? "tGeWm6jBzXOz0kxnuBLtl9dd3KP2")/sabbaths") var sabbaths: [SabbathEvent]
    @Environment(\.dismiss) private var dismiss
    @State var selectedDate = Date()
    @State private var showEventSheet = false
    @State private var imageURL: URL?
    
    var user: User {
        return users.first(where: {$0.email == Auth.auth().currentUser?.email ?? "test1@gmail.com"}) ?? User(id: "tGeWm6jBzXOz0kxnuBLtl9dd3KP2")
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                CalendarMonthView(selectedDate: $selectedDate)
                    .padding()
                
                if selectedDate.getDayOfWeek() != user.sabbath {
                    HStack {
                        Text("\(selectedDate.formatted(date: .abbreviated, time: .omitted))")
                        WeatherView(selectedDate: $selectedDate)
                    }
                    ScheduleView(selectedDate: $selectedDate)
                } else {
                    List {
                        NavigationLink {
                            SabbathView(date: $selectedDate, sabbathEvent: getSabbath() )
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
            .onAppear { // add to VStack - acts like .onAppear
                Task {
                    if let id = user.id { // if this isn't a new user id
                        if let url = await userVM.getImageURL(id: id) { // It should have a url for the image (it may be "")
                            imageURL = url
                        print(imageURL ?? "no image URL")
                        }
                    }
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
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink{
                        UserSetUpView(user: user)
                    } label: {
                        HStack {
                            Text("Hello")
                            Text(user.firstName)
                                .italic()
                            AsyncImage(url: imageURL) { image in
                                image
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 20, height: 20)
                                    .clipShape(Circle())
                            } placeholder: {
                                Image(systemName: "person.circle")
                                    .resizable()
                                    .scaledToFit()
                                    .font(.callout)
                            }
                        }
                        .font(.callout)
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
            .environmentObject(LocationManager())
            .environmentObject(WeatherViewModel())
            .environmentObject(UserViewModel())
    }
}
