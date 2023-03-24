//
//  ContentView.swift
//  PheRechneriOS
//
//  Created by André Reus on 24.03.23.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var dailyPlansData: DailyPlansData
    @State private var selectedFoodEntry: FoodEntry?
    @State private var selectedTab: Int = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView(selectedFoodEntry: $selectedFoodEntry)
                .environmentObject(dailyPlansData)
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Home")
                }
                .tag(0)
            
            RecentFoodEntriesView(selectedFoodEntry: $selectedFoodEntry) {
                selectedTab = 0
            }
                .environmentObject(dailyPlansData)
                .tabItem {
                    Image(systemName: "clock.fill")
                    Text("Recent")
                }
                .tag(1)
            
            SettingsView()
                .environmentObject(dailyPlansData)
                .tabItem {
                    Image(systemName: "gearshape.fill")
                    Text("Settings")
                }
                .tag(2)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(DailyPlansData())
    }
}
