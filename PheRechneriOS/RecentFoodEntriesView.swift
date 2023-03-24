//
//  RecentFoodEntriesView.swift
//  PheRechneriOS
//
//  Created by André Reus on 23.03.23.
//

import SwiftUI

struct RecentFoodEntriesView: View {
    @EnvironmentObject var dailyPlansData: DailyPlansData
    @Binding var selectedFoodEntry: FoodEntry?
    @State private var searchText: String = ""
    var onEntrySelected: (() -> Void)?

    private func recentFoodEntries(from dailyPlans: [DailyPlan]) -> [FoodEntry] {
        let entries = dailyPlans.flatMap { $0.foodEntries }
        let sortedEntries = entries.sorted { $0.timestamp > $1.timestamp }
        let uniqueEntries = Array(NSOrderedSet(array: sortedEntries)) as! [FoodEntry]

        return uniqueEntries.filter { searchText.isEmpty || $0.name.lowercased().contains(searchText.lowercased()) }
    }

    var body: some View {
        List {
            TextField("Search", text: $searchText)
                .padding(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                .background(Color(.systemGray6))
                .cornerRadius(8)
                .padding(.horizontal)
            
            ForEach(recentFoodEntries(from: dailyPlansData.dailyPlans), id: \.id) { entry in
                Button(action: {
                    selectedFoodEntry = entry
                    searchText = ""
                    onEntrySelected?()
                }) {
                    VStack(alignment: .leading) {
                        Text(entry.name)
                        Text("Phenylalanine per 100g: \(entry.phenylalanine / entry.weight * 100, specifier: "%.2f") mg")
                    }
                }
            }
        }
        .listStyle(PlainListStyle())
        .navigationTitle("Recent Food Entries")
    }
}

struct RecentFoodEntriesView_Previews: PreviewProvider {
    static var previews: some View {
        RecentFoodEntriesView(selectedFoodEntry: .constant(nil))
            .environmentObject(DailyPlansData())
    }
}
