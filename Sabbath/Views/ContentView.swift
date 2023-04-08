//
//  ContentView.swift
//  Sabbath
//
//  Created by Jasmine on 4/4/23.
//
import SwiftUI
import Foundation
import Combine
import Firebase
import FirebaseFirestore
import FirebaseFirestoreSwift

struct ContentView: View {
    @EnvironmentObject var locationManager: LocationManager
    @FirestoreQuery(collectionPath: "users") var users: [User]
    @Environment(\.dismiss) private var dismiss
    @State var currentDate = Date()
    @State var selectedDate = Date()
    @State var calTasks: [Date: [CalendarTask]] = [:]
    @State var reminders: [Date: [Reminder]] = [:]
    //@State var events: [Date: [Event]] = [:]
    @State private var showEventSheet = false
    
    var user: User {
        return users.first(where: {$0.email == Auth.auth().currentUser?.email ?? ""}) ?? User()
    }
    
    // addressing the PreviewProvider crash
    var previewRunning = false
    
    @State var selectedDateEvents: [Event] = []
    
    // variable with correct user.id after onAppear of view
    @FirestoreQuery(collectionPath: "users/\(Auth.auth().currentUser?.uid ?? "")/\(Date().getFullDate())") var events: [Event]
    
    var body: some View {
        NavigationStack {
            VStack {
                CalendarMonthView(selectedDate: $selectedDate)
                    .padding()
                ScheduleView(user: user, selectedDate: $selectedDate)
            }
            .sheet(isPresented: $showEventSheet) {
                EventDetailView(user: user, event: Event(startDate: selectedDate, endDate: (selectedDate + (60*60))))
            }
            .toolbar {
                if selectedDate.getDayOfWeek() != user.sabbath {
                    ToolbarItemGroup(placement: .bottomBar) {
                        Button("Add to Schedule") {
                            showEventSheet.toggle()
                        }
                        .buttonStyle(.bordered)
                    }
                }
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    Text("Hello \(user.firstName) \(user.lastName)")
                    NavigationLink{
                        UserSetUpView(user: user)
                    } label: {
                        Image(systemName: "person.crop.square")
                    }
                }
            }
        }
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(previewRunning: true)
            .environmentObject(LocationManager())
    }
}
