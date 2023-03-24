//
//  DailyPlansData.swift
//  PheRechneriOS
//
//  Created by André Reus on 23.03.23.
//

import SwiftUI

class DailyPlansData: ObservableObject {
    @Published var dailyPlans: [DailyPlan] = []

    init() {
        loadDailyPlans()
    }
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }()

    private let dateTimeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }()

    func loadDailyPlans() {
        if let dailyPlansData = UserDefaults.standard.data(forKey: "dailyPlans"),
           let decoded = try? JSONDecoder().decode([DailyPlan].self, from: dailyPlansData) {
            dailyPlans = decoded
        } else {
            dailyPlans = []
        }
    }

    func saveDailyPlans() {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(dailyPlans) {
            UserDefaults.standard.set(encoded, forKey: "dailyPlans")
        }
    }
    
    func exportAsCSV() -> String {
        var csvText = "Date, Food Name, Weight (g), Phenylalanine (mg), Phenylalanine per 100g (mg), Timestamp\n"
        
        for dailyPlan in dailyPlans {
            for foodEntry in dailyPlan.foodEntries {
                let date = dateFormatter.string(from: dailyPlan.date)
                let timestamp = dateTimeFormatter.string(from: foodEntry.timestamp)
                let phenylalaninePer100g = foodEntry.phenylalanine / foodEntry.weight * 100
                let row = "\(date), \(foodEntry.name), \(foodEntry.weight), \(foodEntry.phenylalanine), \(phenylalaninePer100g), \(timestamp)\n"
                csvText.append(row)
            }
        }
        
        return csvText
    }

    func resetDailyPlans() {
        dailyPlans = []
        saveDailyPlans()
    }
}
