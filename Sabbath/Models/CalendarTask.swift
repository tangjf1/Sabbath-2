//
//  CalendarTask.swift
//  Sabbath
//
//  Created by Jasmine on 4/5/23.
//

import Foundation

struct CalendarTask: Identifiable {
    let id = UUID()
    let title: String
    let dueDate: Date
}
