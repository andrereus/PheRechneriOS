//
//  DailyPlan.swift
//  PheRechneriOS
//
//  Created by André Reus on 23.03.23.
//

import SwiftUI

struct DailyPlan: Identifiable, Codable {
    var id = UUID()
    var date: Date
    var foodEntries: [FoodEntry]
}

struct FoodEntry: Identifiable, Codable, Equatable {
    var id = UUID()
    var name: String
    var phenylalanine: Double
    var weight: Double
    var timestamp: Date
}
