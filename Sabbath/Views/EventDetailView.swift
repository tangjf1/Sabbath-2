//
//  EventDetailView.swift
//  Sabbath
//
//  Created by Jasmine on 4/7/23.
//

import SwiftUI

struct EventDetailView: View {
    enum SaveAlert {
        case sabbath, endDate
        
        var alert: String {
            switch self {
            case .sabbath:
                return "Date chosen falls on your chosen day of Sabbath"
            case .endDate:
                return "Invalid start or end date"
            }
        }
    }
    @State private var saveAlert = SaveAlert.sabbath
    @Environment(\.dismiss) private var dismiss
    @StateObject var eventVM = EventViewModel()
    @State var user: User
    @State var event: Event
    @State private var showPlaceLookupSheet = false
    // to show alert if user tries to write a review on new Spot before saving it first
    @State private var showSaveAlert = false
    @State var oldEventDate = Date().getFullDate()
    @FocusState private var notesIsFocused: Bool
    var body: some View {
        NavigationStack {
            ZStack {
                List{
                    TextField("Title", text: $event.title)
                        .font(.title)
                        .textFieldStyle(.roundedBorder)
                        .listRowSeparator(.hidden)
                    
                    Toggle("Set Notification for Reminder:", isOn: $event.notification )
                        .padding(.vertical)
                        .tint(.accentColor)
                        .listRowSeparator(.hidden)
                    
                    DatePicker("Starting Time", selection: $event.startDate)
                        .listRowSeparator(.hidden)
                        .onChange(of: event.startDate) { _ in
                            event.endDate = event.startDate + (60*60)
                        }
                    
                    DatePicker("Ending Time", selection: $event.endDate)
                        .listRowSeparator(.hidden)
                        .padding(.bottom)
                    
                    Group{
                        Text("Location")
                            .padding(.top)
                        
                        VStack (spacing: 2){
                            TextField("Location Name", text: $event.locationName, axis: .vertical)
                                .textFieldStyle(.roundedBorder)
                            TextField("Address", text: $event.locationAddress, axis: .vertical)
                                .textFieldStyle(.roundedBorder)
                                .font(.callout)
                        }
                        Button {
                            showPlaceLookupSheet.toggle()
                        } label: {
                            HStack {
                                Spacer()
                                Image(systemName: "magnifyingglass")
                                Text("Lookup Place")
                            }
                            .foregroundColor(.accentColor)
                        }
                    }
                    .listRowSeparator(.hidden)
                    
                    Text("Notes")
                    TextField("Notes", text: $event.description, axis: .vertical)
                        .submitLabel(.done)
                        .focused($notesIsFocused)
                        .onChange(of: event.description) { newValue in
                            guard let newValueLastChar = newValue.last else {return}
                            if newValueLastChar == "\n" {
                                event.description.removeLast()
                                notesIsFocused = false
                            }
                        }
                        .textFieldStyle(.roundedBorder)
                        .listRowSeparator(.hidden)
                }
                .listStyle(.plain)
                .sheet(isPresented: $showPlaceLookupSheet) {
                    PlaceLookupView(event: $event)
                }
                .toolbar {
                    ToolbarItem (placement: .navigationBarLeading) {
                        Button("Cancel") {
                            dismiss()
                        }
                    }
                    ToolbarItem (placement: .navigationBarTrailing) {
                        Button("\(event.id == nil ? "Save" : "Update")") {
                            if (event.startDate.getDayOfWeek() == user.sabbath) || (event.endDate.getDayOfWeek() == user.sabbath) {
                                saveAlert = .sabbath
                                showSaveAlert.toggle()
                            } else if (event.endDate < event.startDate) {
                                saveAlert = .endDate
                                showSaveAlert.toggle()
                            } else {
                                print("oldEventDate: \(oldEventDate)")
                                Task {
                                    let success = await eventVM.saveEvent(user: user, event: event, eventCollection: oldEventDate)
                                    
                                    if success {
                                        dismiss()
                                    } else {
                                        print("😡 ERROR saving data in EventView")
                                    }
                                }
                            }
                        }
                        .disabled(event.title.isEmpty)
                    }
                    if event.id != nil {
                        ToolbarItemGroup(placement: .bottomBar) {
                            
                            Spacer()
                            Button {
                                Task {
                                    let success = await eventVM.deleteEvent(user: user, event: event, eventCollection: oldEventDate)
                                    
                                    if success {
                                        dismiss()
                                    } else {
                                        print("😡 ERROR deleting data in EventView")
                                    }
                                }
                            } label: {
                                Image(systemName: "trash")
                            }
                            
                        }
                    }
                    
                }
                .alert("Cannot Save Event", isPresented: $showSaveAlert) {
                    Button("Edit Schedule Details", role: .cancel) {}
                } message: {
                    Text(saveAlert.alert)
                }
                .navigationBarBackButtonHidden()
                .navigationBarTitleDisplayMode(.inline)
                
                if eventVM.isLoading {
                    ProgressView()
                        .scaleEffect(2)
                }
            }
        }
        .onAppear {
            oldEventDate = event.startDate.getFullDate()
            print("oldEventDate: \(oldEventDate)")
        }
    }
}

struct EventDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            EventDetailView(user: User(), event: Event(id: "12345"))
        }
    }
}
