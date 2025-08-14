//
//  SpreadsheetSettingsView.swift
//  InventoryManager
//
//  Created by Milan Parađina on 13.08.2025..
//

import SwiftUI

struct SpreadsheetSettingsView: View {
    @EnvironmentObject private var selectionService: SelectionService
    var body: some View {
        Button {
            
        } label: {
            Text("Get Spreadsheets from Google Drive")
        }
        
        NavigationLink {
            SpreadsheetPickerView(viewModel: SpreadsheetPickerViewModel(selectionService: selectionService))
        } label: {
            Text("Pick a Spreadsheet")
        }
    }
}

#Preview {
    SpreadsheetSettingsView()
}
