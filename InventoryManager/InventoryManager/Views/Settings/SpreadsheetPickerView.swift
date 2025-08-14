//
//  SpreadsheetPickerView.swift
//  InventoryManager
//
//  Created by Milan Parađina on 13.08.2025..
//

import SwiftUI

struct SpreadsheetPickerView: View {
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(key: "name", ascending: true)],
        animation: .bouncy)
    private var spreadsheets: FetchedResults<Spreadsheet>
    @StateObject var viewModel: SpreadsheetPickerViewModel
    
    var body: some View {
        List(spreadsheets, id: \.objectID) { spreadsheet in
                NavigationLink {
                    SheetPickerView(viewModel: viewModel, spreadsheet: spreadsheet)
                } label: {
                    Text((viewModel.selectedSpreadsheet == spreadsheet ? "\(spreadsheet.name ?? "Untitled spreadsheet") (selected)" : spreadsheet.name) ?? "Untitled spreadsheet")
                        .fontWeight(viewModel.selectedSpreadsheet == spreadsheet ? .bold : .medium)
                        .foregroundStyle(viewModel.selectedSpreadsheet == spreadsheet ? Color.purpleColor : .primary)
                }
        }
        .onAppear {
            viewModel.loadSelection()
        }
    }
}

#Preview {
    //SpreadsheetPickerView()
}
