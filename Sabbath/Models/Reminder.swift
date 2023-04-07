//
//  Reminder.swift
//  Sabbath
//
//  Created by Jasmine on 4/4/23.
//

import Foundation

struct Reminder: Identifiable {
    let id = UUID()
    let title: String
    let dueDate: Date
}
