//
//  SleepCompanionApp.swift
//  SleepCompanion
//
//  Created by nicolas on 2026/6/4.
//

import SwiftUI

@main
struct SleepCompanionApp: App {
    @StateObject private var audioManager = AudioManager()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(audioManager)
        }
    }
}
