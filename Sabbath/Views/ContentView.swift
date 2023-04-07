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
    
    // variable with correct user.id after onAppear of view
    @FirestoreQuery(collectionPath: "users/\(Auth.auth().currentUser?.uid ?? "")/events") var events: [Event]
    
    var body: some View {
        NavigationStack {
            VStack {
                CalendarMonthView(selectedDate: $selectedDate)
                    .padding()
                
                if selectedDate.getDayOfWeek() != user.sabbath {
                    HStack {
                        Button(action: {
                            let calTask = CalendarTask(title: "New Task", dueDate: selectedDate)
                            if calTasks[selectedDate] != nil {
                                calTasks[selectedDate]?.append(calTask)
                            } else {
                                calTasks[selectedDate] = [calTask]
                            }
                        }) {
                            Text("Add Task")
                        }
                        
                        Button(action: {
                            let reminder = Reminder(title: "New Reminder", dueDate: selectedDate)
                            if reminders[selectedDate] != nil {
                                reminders[selectedDate]?.append(reminder)
                            } else {
                                reminders[selectedDate] = [reminder]
                            }
                        }) {
                            Text("Add Reminder")
                        }
                        
                        Button("Add Event") {
                            showEventSheet.toggle()
                        }
                    }
                    .buttonStyle(.borderedProminent)
                }
                
                Spacer()
                Text("Selected Date: \(selectedDate.formatted(date: .abbreviated, time: .omitted))")
                
                List {
                    if let selectedcalTasks = calTasks[selectedDate] {
                        Text("Tasks:")
                        ForEach(selectedcalTasks, id: \.id) { calTask in
                            Text(calTask.title)
                        }
                    }
                    
                    if let selectedReminders = reminders[selectedDate] {
                        Text("Reminders:")
                        ForEach(selectedReminders, id: \.id) { reminder in
                            Text(reminder.title)
                        }
                    }
                    
                    Text("Schedule:")
                    ForEach(events, id: \.id) { event in
                        Text(event.title)
                    }
                }
                .listStyle(.plain)
            }
            .sheet(isPresented: $showEventSheet) {
                EventDetailView(user: user, event: Event())
            }
            .toolbar {
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
        .onAppear{
            if !previewRunning && (Auth.auth().currentUser?.uid != nil)
            {
                print("events path: users/\(Auth.auth().currentUser?.uid ?? "")/events")
                $events.path = " users/\(Auth.auth().currentUser?.uid ?? "")/events"
                print("events: \(events)")
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
