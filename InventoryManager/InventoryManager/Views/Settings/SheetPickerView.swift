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
            ZStack {
                LinearGradient(colors: [Color.purple.opacity(0.18), Color.blue.opacity(0.18)], startPoint: .topLeading, endPoint: .bottomTrailing)
                    .ignoresSafeArea(edges: .all)
                
                if let sheets = spreadsheet.sheets?.allObjects as? [Sheet] {
                    List(sheets, id: \.objectID) { sheet in
                        Button {
                            guard let spreadsheetId = spreadsheet.spreadsheetId,
                               let sheetId = sheet.name else { return }
                            withAnimation (.spring(response: 0.35, dampingFraction: 0.8)){
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
                                        .symbolEffect(.bounce.wholeSymbol, value: isSheetSelected)
                                        .font(.largeTitle)
                                        .foregroundStyle(Color.purpleColor)
                                }
                            }
                            .onChange(of: viewModel.selectedSheet?.objectID, { oldValue, newValue in
                                if newValue == sheet.objectID {
                                    isSheetSelected.toggle()
                                }
                            })
                        }
                    }
                    .scrollContentBackground(.hidden)
                }
            }
        }
        .navigationTitle(Text(spreadsheet.name ?? "Untitled Spreadsheet"))
    }
}

#Preview {
    //SheetPickerView()
}
