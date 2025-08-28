//
//  SpreadsheetSettingsView.swift
//  InventoryManager
//
//  Created by Milan Parađina on 13.08.2025..
//

import SwiftUI

struct SpreadsheetSettingsView: View {
    @EnvironmentObject private var selectionService: SelectionService

    @StateObject var settingsVm: SettingsViewModel
    @State private var isLoadingPresented = false
    
    var body: some View {
        ZStack {
            LinearGradient(colors: [Color.purple.opacity(0.18), Color.blue.opacity(0.18)], startPoint: .topLeading, endPoint: .bottomTrailing)
                .ignoresSafeArea(edges: .all)
            
            VStack(spacing: 15) {
                Text("Spreadsheet settings")
                    .font(.largeTitle)
                Button {
                    Task {
                        await settingsVm.performTaskWithLoading {
                            try await settingsVm.syncGoogleSpreadsheets()
                        }
                    }
                    
                } label: {
                    SpreadsheetSyncCard()
                }
                .padding()
                
                NavigationLink {
                    SpreadsheetPickerView(viewModel: SpreadsheetPickerViewModel(selectionService: selectionService))
                } label: {
                    FeatureCard(title: "Pick a Spreadsheet", subtitle: "Choose a Spreadsheet & Sheet to send the scanned information", systemImage: "document.on.document.fill", isPressed: true)
                }
                .padding()
                Spacer()
            }
            .loadingOverlay(
                $settingsVm.isLoading,
                text: settingsVm.currentSheet,
                symbols: ["document.on.document.fill", "document.viewfinder.fill", "document.badge.arrow.up.fill"])
            .navigationBarBackButtonHidden(isLoadingPresented)
            .errorAlert(error: $settingsVm.settingsError)
        }
    }
}

#Preview {
    SpreadsheetSettingsView(settingsVm: SettingsViewModel())
}
