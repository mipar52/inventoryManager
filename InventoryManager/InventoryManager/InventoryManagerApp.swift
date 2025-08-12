//
//  InventoryManagerApp.swift
//  InventoryManager
//
//  Created by Milan Parađina on 01.08.2025..
//

import SwiftUI
import GoogleSignIn

@main
struct InventoryManagerApp: App {
    @StateObject private var databaseService = DatabaseService()
    @AppStorage(UserDefaultsConstants.isUserFirstTime) var isUserFirstTime: Bool = true
    
    var body: some Scene {
        WindowGroup {
            #if DEBUG
            InitialLoginScreen()
                .handleGoogleRestoreSignIn()
                .environment(\.managedObjectContext, databaseService.container.viewContext)
                .environmentObject(databaseService)
            #else
            Group {
                if isUserFirstTime {
                    InitialLoginScreen()
                        
                } else {
                    MainView()
                }
            }
            .handleGoogleRestoreSignIn()
            .environment(\.managedObjectContext, databaseService.container.viewContext)
            .environmentObject(databaseService)
            #endif
           // ContentView()
           //     .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
