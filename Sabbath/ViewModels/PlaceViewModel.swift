//
//  PlaceViewModel.swift
//  PlaceLookupDemo
//
//  Created by Jasmine on 3/23/23.
//

import Foundation
import MapKit

@MainActor
class PlaceViewModel: ObservableObject {
    @Published var places: [Place] = []
    
    func search(text: String, region: MKCoordinateRegion) {
        let searchRequest = MKLocalSearch.Request()
        searchRequest.naturalLanguageQuery = text
        searchRequest.region = region // helps narrow down search to specific region
        
        let search = MKLocalSearch(request: searchRequest) // does the actual searching using the searchRequest object
        
        search.start { response, error in
            guard let response = response else {
                print("ERROR: \(error?.localizedDescription ?? "Unknown Error")")
                return
            }
            
            // if response is not nil, search.start returns array of locations that match the search text
            self.places = response.mapItems.map(Place.init) // or map { Place(mapItem: $0) }
        }
        
    }
}
