//
//  MainView.swift
//  InventoryManager
//
//  Created by Milan Parađina on 01.08.2025..
//

import SwiftUI

struct MainView: View {
    @EnvironmentObject var selectionService: SelectionService
    @EnvironmentObject var db: DatabaseService
    
    var body: some View {
        NavigationView {
            TabView {
                Tab {
                    ScanPickerView(selectionService: selectionService)
                } label: {
                    TabLabelView(uiImageString: "barcode.viewfinder", labelString: "Scan")
                }
                Tab {
                    ScanHistoryView(vm: ScanHistoryViewModel(db: db))
                } label: {
                    TabLabelView(uiImageString: "list.bullet", labelString: "Scan History")
                }
                
                Tab {
                    SettingsView()
                } label: {
                    TabLabelView(uiImageString: "gear", labelString: "Settings")
                }
            }
            .navigationBarHidden(true)
        }
    }
}

#Preview {
    MainView()
}
