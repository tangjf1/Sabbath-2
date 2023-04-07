//
//  Event.swift
//  Sabbath
//
//  Created by Jasmine on 4/4/23.
//

import Foundation
import Firebase
import FirebaseFirestoreSwift // access to document id property wrapper

struct Event: Identifiable, Codable, Equatable {
    @DocumentID var id: String?
    var title = ""
    var startDate = Date()
    var endDate = Date() + (60*60)
    var description = ""
    var notification = false
    var locationName = ""
    var locationAddress = ""
    
    var dictionary: [String: Any] {
        return  ["title" : title, "startDate" : Timestamp(date: startDate), "endDate" : Timestamp(date: endDate), "description" : description, "notification": notification, "locationName": locationName, "locationAddress": locationAddress]
    }
}
