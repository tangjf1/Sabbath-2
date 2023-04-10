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
    var journalPrompt = ""
    var journalEntry = ""
    
    var dictionary: [String: String] {
        return  ["affirmation" : affirmation, "date" : date, "journalPrompt": journalPrompt, "journalEntry": journalEntry]
    }
}
