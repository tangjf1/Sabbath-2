//
//  EventDetailView.swift
//  Sabbath
//
//  Created by Jasmine on 4/7/23.
//

import SwiftUI
import MapKit

struct EventDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject var eventVM = EventViewModel()
    @EnvironmentObject var locationManager: LocationManager
    @State var user: User
    @State var event: Event
    @State private var showPlaceLookupSheet = false
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
                    Button("Save") {
                        Task {
                            let success = await eventVM.saveEvent(user: user, event: event)
                            
                            if success {
                                dismiss()
                            } else {
                                print("😡 ERROR saving data in EventView")
                            }
                        }
                    }
                }
                
            }
            .navigationBarBackButtonHidden()
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct EventDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            EventDetailView(user: User(), event: Event())
                .environmentObject(LocationManager())
        }
    }
}
