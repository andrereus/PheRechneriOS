//
//  PheRechneriOSApp.swift
//  PheRechneriOS
//
//  Created by André Reus on 24.03.23.
//

import SwiftUI

@main
struct PheRechneriOSApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(DailyPlansData())
        }
    }
}
