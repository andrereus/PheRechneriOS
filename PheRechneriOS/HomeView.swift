//
//  HomeView.swift
//  PheRechneriOS
//
//  Created by André Reus on 23.03.23.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var dailyPlansData: DailyPlansData
    @AppStorage("dailyTolerance") private var dailyTolerance: Double = 0

    @State private var phenylalaninePer100g: String = ""
    @State private var weightInGrams: String = ""
    @State private var foodName: String = ""
    @State private var selectedDate = Date()
    
    @State private var newFoodEntry: FoodEntry = FoodEntry(name: "", phenylalanine: 0, weight: 0, timestamp: Date())
    @State private var showingAddEntry = false
    @Binding var selectedFoodEntry: FoodEntry?
    
    private var currentDailyPlan: DailyPlan {
        dailyPlansData.dailyPlans.first(where: { Calendar.current.isDate($0.date, inSameDayAs: selectedDate) }) ?? DailyPlan(date: selectedDate, foodEntries: [])
    }
    
    private var phenylalanineAmount: Double {
        let phenylalanineValue = Double(phenylalaninePer100g) ?? 0
        let weightValue = Double(weightInGrams) ?? 0
        return (phenylalanineValue * weightValue) / 100
    }
    
    private var totalPhenylalanine: Double {
        currentDailyPlan.foodEntries.map { $0.phenylalanine }.reduce(0, +)
    }
    
    private func addFoodEntry() {
        let phenylalanine = (Double(phenylalaninePer100g) ?? 0) * (Double(weightInGrams) ?? 0) / 100
        let foodEntry = FoodEntry(name: foodName, phenylalanine: phenylalanine, weight: Double(weightInGrams) ?? 0, timestamp: Date())

        if let index = dailyPlansData.dailyPlans.firstIndex(where: { Calendar.current.isDate($0.date, inSameDayAs: selectedDate) }) {
            dailyPlansData.dailyPlans[index].foodEntries.append(foodEntry)
        } else {
            let newDailyPlan = DailyPlan(date: selectedDate, foodEntries: [foodEntry])
            dailyPlansData.dailyPlans.append(newDailyPlan)
        }

        cleanOldEntries()
        phenylalaninePer100g = ""
        weightInGrams = ""
        foodName = ""
        
        selectedFoodEntry = nil
        
        dailyPlansData.saveDailyPlans()
    }
    
    private func deleteFoodEntry(offsets: IndexSet) {
        if let index = dailyPlansData.dailyPlans.firstIndex(where: { Calendar.current.isDate($0.date, inSameDayAs: selectedDate) }) {
            dailyPlansData.dailyPlans[index].foodEntries.remove(atOffsets: offsets)
            
            dailyPlansData.saveDailyPlans()
        }
    }
    
    private func cleanOldEntries() {
        let oneMonthAgo = Calendar.current.date(byAdding: .month, value: -1, to: Date()) ?? Date()
        dailyPlansData.dailyPlans = dailyPlansData.dailyPlans.filter { $0.date > oneMonthAgo }
    }
    
    var body: some View {
        NavigationView {
            ScrollViewReader { proxy in
                List {
                    Group {
                        Section(header: Text("Calculate Phenylalanine")) {
                            TextField("Food name", text: $foodName)
                            TextField("Phenylalanine per 100g", text: $phenylalaninePer100g).keyboardType(.decimalPad)
                            TextField("Weight in grams", text: $weightInGrams).keyboardType(.decimalPad)
                            Text("Phenylalanine: \(phenylalanineAmount, specifier: "%.2f") mg")
                            Button("Add to daily plan") {
                                addFoodEntry()
                                phenylalaninePer100g = ""
                                weightInGrams = ""
                                foodName = ""
                            }.disabled(foodName.isEmpty || phenylalaninePer100g.isEmpty || weightInGrams.isEmpty)
                        }
                    }

                    Group {
                        Section(header: Text("Daily Plan")) {
                            DatePicker("Select date", selection: $selectedDate, displayedComponents: .date)
                            Text("Total Phenylalanine: \(totalPhenylalanine, specifier: "%.2f") mg")
                            Text("Remaining Phenylalanine: \((dailyTolerance - totalPhenylalanine), specifier: "%.2f") mg")
                            ForEach(currentDailyPlan.foodEntries) { foodEntry in
                                HStack {
                                    VStack(alignment: .leading) {
                                        Text("\(foodEntry.name)")
                                        Text("Weight: \(foodEntry.weight, specifier: "%.1f") g")
                                        Text("Phenylalanine: \(foodEntry.phenylalanine, specifier: "%.2f") mg")
                                    }
                                    Spacer()
                                    Text(foodEntry.timestamp, style: .time)
                                }
                            }
                            .onDelete(perform: deleteFoodEntry)
                        }
                    }
                }
                .listStyle(InsetGroupedListStyle())
                .onChange(of: selectedFoodEntry) { entry in
                    if let entry = entry {
                        foodName = entry.name
                        phenylalaninePer100g = "\(entry.phenylalanine / entry.weight * 100)"
                    }
                }
            }
            .navigationTitle("Phe Rechner")
            .onAppear {
                if let entry = selectedFoodEntry {
                    newFoodEntry.name = entry.name
                    newFoodEntry.weight = entry.weight
                    newFoodEntry.phenylalanine = entry.phenylalanine
                }
            }
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    @State static var selectedFoodEntry: FoodEntry? = nil
    
    static var previews: some View {
        HomeView(selectedFoodEntry: $selectedFoodEntry)
            .environmentObject(DailyPlansData())
    }
}
