//
//  PlaceLookupView.swift
//  PlaceLookupDemo
//
//  Created by Jasmine on 3/23/23.
//

import SwiftUI
import MapKit

struct PlaceLookupView: View {
    @EnvironmentObject var locationManager: LocationManager
    @StateObject var placeVM = PlaceViewModel()
    @State private var searchText = ""
    @Environment(\.dismiss) private var dismiss
    @Binding var event: Event
    
    var body: some View {
        NavigationStack {
            List(placeVM.places) { place in
                VStack (alignment: .leading){
                    Text(place.name)
                        .font(.title2)
                    
                    Text(place.address)
                        .font(.callout)
                }
                .onTapGesture {
                    event.locationName = place.name
                    event.locationAddress = place.address
                    dismiss()
                }
            }
            .listStyle(.plain)
            .searchable(text: $searchText)
            .autocorrectionDisabled()
            .onChange(of: searchText, perform: { text in
                if !text.isEmpty {
                    placeVM.search(text: text, region: locationManager.region)
                }
                
                else {
                    placeVM.places = []
                }
            })
            .toolbar {
                ToolbarItem(placement: .automatic) {
                    Button {
                        dismiss()
                    } label: {
                        Text("Dismiss")
                    }
                    
                }
            }
        }
    }
}

struct PlaceLookupView_Previews: PreviewProvider {
    static var previews: some View {
        PlaceLookupView(event: .constant(Event()))
            .environmentObject(LocationManager())
    }
}
