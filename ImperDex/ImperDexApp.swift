//
//  ImperDexApp.swift
//  ImperDex
//
//  Created by John Newman on 9/10/2025.
//

import SwiftUI
import SwiftData

@main
struct ImperDexApp: App {
    
    let sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Pokemon.self
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        
        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .modelContainer(sharedModelContainer)
        }
    }
}
