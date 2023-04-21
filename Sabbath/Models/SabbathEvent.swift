//
//  Sabbath.swift
//  Sabbath
//
//  Created by Jasmine on 4/10/23.
//

import Foundation
import Firebase
import FirebaseFirestoreSwift // access to document id property wrapper

struct SabbathEvent: Identifiable, Codable, Equatable {
    @DocumentID var id: String?
    var affirmation = ""
    var date = Date().getFullDate()
    var intentionsEntry = ""
    var goalsRating = 0
    var journalPrompt = ""
    var journalEntry = ""
    
    var dictionary: [String: Any] {
        return  ["affirmation" : affirmation, "date" : date, "intentionsEntry": intentionsEntry, "goalsRating": goalsRating, "journalPrompt": journalPrompt, "journalEntry": journalEntry]
    }
}
