//
//  Weather.swift
//  Sabbath
//
//  Created by Jasmine on 4/19/23.
//

import Foundation

struct Daily: Codable, Identifiable {
    var id: String?
    var time = ""
    var temperature_2m_max = -500.00
    var temperature_2m_min = -500.00
    var precipitation_sum = -500.00
}

