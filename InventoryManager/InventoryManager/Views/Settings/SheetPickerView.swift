//
//  SheetPickerView.swift
//  InventoryManager
//
//  Created by Milan Parađina on 13.08.2025..
//

import SwiftUI

struct SheetPickerView: View {
    @StateObject var viewModel: SpreadsheetPickerViewModel
    var spreadsheet: Spreadsheet
    @State var isSheetSelected: Bool = true
    
    var body: some View {
        NavigationView {
            if let sheets = spreadsheet.sheets?.allObjects as? [Sheet] {
                List(sheets, id: \.objectID) { sheet in
                    Button {
                        if let spreadsheetId = spreadsheet.spreadsheetId,
                           let sheetId = sheet.sheetId {
                            viewModel.setSelection(with: spreadsheetId, sheet: sheetId)
                        }
                    } label: {
                        HStack {
                            Text(sheet.name ?? "Untitled sheet")
                                .fontWeight(viewModel.selectedSheet == sheet ? .bold : .medium)
                                .foregroundStyle(viewModel.selectedSheet == sheet ? Color.purpleColor : .primary)
                            
                            if (viewModel.selectedSheet == sheet) {
                                Spacer()
                                Image(systemName: "checkmark.circle.fill")
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle(Text(spreadsheet.name ?? "Untitled Spreadsheet"))
    }
}

#Preview {
    //SheetPickerView()
}
