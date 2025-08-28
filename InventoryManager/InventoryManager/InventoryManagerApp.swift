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
    @StateObject private var databaseService: DatabaseService
    @StateObject private var selectionService: SelectionService
    
    @AppStorage(UserDefaultsConstants.isUserFirstTime) var isUserFirstTime: Bool = true
    
    init() {
        let db = DatabaseService()
        _databaseService = StateObject(wrappedValue: db)
        _selectionService = StateObject(wrappedValue: SelectionService(dbService: db))
    }
    
    var body: some Scene {
        WindowGroup {
            #if DEBUG
            InitialLoginScreen()
                .handleGoogleRestoreSignIn()
                .environmentObject(databaseService)
                .environment(\.managedObjectContext, databaseService.container.viewContext)
                .environmentObject(selectionService)
            #else
            Group {
                if isUserFirstTime {
                    InitialLoginScreen()
                        
                } else {
                    MainView()
                }
            }
            .handleGoogleRestoreSignIn()
            .environmentObject(databaseService)
            .environment(\.managedObjectContext, databaseService.container.viewContext)
            .environmentObject(selectionService)
            #endif
           // ContentView()
           //     .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
