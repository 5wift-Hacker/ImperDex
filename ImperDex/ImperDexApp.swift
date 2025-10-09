//
//  ImperDexApp.swift
//  ImperDex
//
//  Created by John Newman on 9/10/2025.
//

import SwiftUI
import CoreData

@main
struct ImperDexApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
