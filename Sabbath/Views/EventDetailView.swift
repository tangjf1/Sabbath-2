//
//  EventDetailView.swift
//  Sabbath
//
//  Created by Jasmine on 4/7/23.
//

import SwiftUI
import MapKit

struct EventDetailView: View {
    enum SaveAlert {
        case sabbath, endDate
        
        var alert: String {
            switch self {
            case .sabbath:
                return "Date chosen falls on your chosen day of Sabbath"
            case .endDate:
                return "Invalid end date"
            }
        }
    }
    @State private var saveAlert = SaveAlert.sabbath
    @Environment(\.dismiss) private var dismiss
    @StateObject var eventVM = EventViewModel()
    @EnvironmentObject var locationManager: LocationManager
    @State var user: User
    @State var event: Event
    @State private var showPlaceLookupSheet = false
    // to show alert if user tries to write a review on new Spot before saving it first
    @State private var showSaveAlert = false
    @State var oldEventDate = Date().getFullDate()
    var body: some View {
        NavigationStack {
            List{
                TextField("Event Title", text: $event.title)
                    .font(.title)
                    .textFieldStyle(.roundedBorder)
                    .listRowSeparator(.hidden)
                
                Toggle("Set Notification Before Event:", isOn: $event.notification )
                    .padding(.vertical)
                    .listRowSeparator(.hidden)
                
                DatePicker("Event Start", selection: $event.startDate)
                    .listRowSeparator(.hidden)
                
                DatePicker("Event End", selection: $event.endDate)
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
                .environmentObject(LocationManager())
        }
    }
}
