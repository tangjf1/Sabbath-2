//
//  Place.swift
//  PlaceLookupDemo
//
//  Created by Jasmine on 3/23/23.
//

import Foundation
import MapKit

struct Place: Identifiable {
    let id = UUID().uuidString
    
    private var mapItem: MKMapItem
    
    init(mapItem: MKMapItem) {
        self.mapItem = mapItem
    }
    
    var name: String {
        self.mapItem.name ?? ""
    }
    
    var address: String {
        let placemark = self.mapItem.placemark
        var streetAddress = ""
        var cityStateZipCode = ""
        
        streetAddress = placemark.subThoroughfare ?? "" // Address #
        if let street = placemark.thoroughfare { // Street name without the address number
            streetAddress = streetAddress.isEmpty ? "\(street), " : "\(streetAddress) \(street), "
        }
        
        cityStateZipCode = placemark.locality ?? ""
        if let state = placemark.administrativeArea {
            cityStateZipCode = cityStateZipCode.isEmpty ? state : "\(cityStateZipCode), \(state)"
        }
        
        if let zipCode = placemark.postalCode {
            cityStateZipCode = cityStateZipCode.isEmpty ? zipCode : "\(cityStateZipCode) \(zipCode)"
        }
        
        return streetAddress + cityStateZipCode
    }
}
