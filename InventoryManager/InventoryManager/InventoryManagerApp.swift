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
    @AppStorage(UserDefaultsConstants.isUserFirstTime) var isUserFirstTime: Bool = true
    
    var body: some Scene {
        WindowGroup {
            #if DEBUG
            InitialLoginScreen()
            #else
            if isUserFirstTime {
                InitialLoginScreen()
            } else {
                MainView()
            }
            #endif
           // ContentView()
           //     .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
