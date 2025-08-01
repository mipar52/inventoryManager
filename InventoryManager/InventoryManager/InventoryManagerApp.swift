//
//  InventoryManagerApp.swift
//  InventoryManager
//
//  Created by Milan Parađina on 01.08.2025..
//

import SwiftUI

@main
struct InventoryManagerApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
