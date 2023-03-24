//
//  SettingsView.swift
//  PheRechneriOS
//
//  Created by André Reus on 23.03.23.
//

import SwiftUI
import Foundation
import UIKit

struct SettingsView: View {
    @EnvironmentObject var dailyPlansData: DailyPlansData
    @AppStorage("dailyTolerance") private var dailyTolerance: Double = 0
    
    @State private var showingAlert = false
    @State private var showAlert = false
    
    private func exportData() {
        let fileName = "daily_plans_data.csv"
        let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent(fileName)

        let csvText = dailyPlansData.exportAsCSV()

        do {
            try csvText.write(to: path, atomically: true, encoding: .utf8)
            let av = UIActivityViewController(activityItems: [path], applicationActivities: nil)
            
            if let windowScene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene,
               let rootViewController = windowScene.windows.first?.rootViewController {
                rootViewController.present(av, animated: true, completion: nil)
            }
        } catch {
            print("Failed to export data: \(error)")
        }
    }
    
    private func resetData() {
        dailyPlansData.resetDailyPlans()
    }

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Daily Tolerance")) {
                    TextField("Daily Tolerance (mg)", value: $dailyTolerance, formatter: NumberFormatter())
                        .keyboardType(.decimalPad)
                }
                
                Section(header: Text("Data")) {
                    Button("Export Data") {
                        exportData()
                    }
                    
                    Button("Reset all data") {
                        showAlert = true
                    }
                    .alert(isPresented: $showAlert) {
                        Alert(title: Text("Reset All Data"),
                              message: Text("Are you sure you want to reset all data? This action cannot be undone."),
                              primaryButton: .destructive(Text("Reset")) {
                            resetData()
                        },
                              secondaryButton: .cancel())
                    }
                }
            }
        }
        .navigationTitle("Settings")
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
