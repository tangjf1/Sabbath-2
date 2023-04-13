//
//  User.swift
//  Sabbath
//
//  Created by Jasmine on 4/5/23.
//

import Foundation
import Firebase // For access to authentication and user info
import FirebaseFirestoreSwift // access to document id property wrapper

enum Sabbath: String, Codable, CaseIterable {
    case Sun, Mon, Tue, Wed, Thu, Fri, Sat
}

struct User: Identifiable, Codable, Equatable {
    @DocumentID var id: String?
    var email = Auth.auth().currentUser?.email ?? ""
    var firstName = ""
    var lastName = ""
    var sabbath: String = Sabbath.Sun.rawValue
    var birthday = Date() - (60*60*24*365*10)
    
    var dictionary: [String: Any] {
        return  ["email" : email, "firstName" : firstName, "lastName": lastName, "sabbath": sabbath, "birthday": Timestamp(date: birthday)]
    }
}
