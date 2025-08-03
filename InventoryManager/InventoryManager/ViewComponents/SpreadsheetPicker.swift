//
//  SpreadsheetPicker.swift
//  InventoryManager
//
//  Created by Milan Parađina on 03.08.2025..
//

import SwiftUI

struct SpreadsheetPicker: View {
    @ObservedObject var viewModel: ScannerViewModel
    @State var selectedSpreadsheetName: String = "Select Spreadsheet"
    @State var selectedSheettName: String = "Select Sheet"

    var body: some View {
        VStack(spacing: 16) {
            Menu(viewModel.selectedSpreadsheet?.name ?? "Select Spreadsheet") {
                ForEach(viewModel.spreadsheets ?? [], id: \.self) { spreadsheet in
                    Menu(spreadsheet.name) {
                        ForEach(spreadsheet.sheets, id: \.self) { sheet in
                            Button {
                                viewModel.selectedSpreadsheet = spreadsheet
                                viewModel.selectedSheet = sheet
                            } label: {
                                HStack {
                                    Text(sheet.name)
                                    if viewModel.selectedSheet?.id == sheet.id &&
                                        viewModel.selectedSpreadsheet?.id == spreadsheet.id {
                                        Spacer()
                                        Image(systemName: "checkmark")
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .frame(width: 200, height: 50)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .padding()

            // First Picker: Spreadsheets
//            Picker("Select Spreadsheet", selection: $viewModel.selectedSpreadsheet) {
//                ForEach(viewModel.spreadsheets ?? [], id: \.id) { sheet in
//                    Text(sheet.name).tag(Optional(sheet)) // tag must match the binding type
//                }
//            }
//            .pickerStyle(.menu) // or .wheel/.segmented depending on UX
//            .frame(width: 200, height: 50)
//            .background(.ultraThinMaterial)
//            .clipShape(RoundedRectangle(cornerRadius: 12))
//
//            // Second Picker: Sheets within selected spreadsheet
//            if let sheets = viewModel.selectedSpreadsheet?.sheets {
//                Picker(selection: $viewModel.selectedSheet) {
//                    ForEach(sheets, id: \.id) { sheet in
//                        Text(sheet.name).tag(Optional(sheet))
//                    }
//                } label: {
//                    Text("Select Sheet")
//                }
//                .pickerStyle(.menu)
//                .frame(width: 200, height: 50)
//                .background(.ultraThinMaterial)
//                .clipShape(RoundedRectangle(cornerRadius: 12))
//            }
        }
    }
}

#Preview {
    SpreadsheetPicker(viewModel: ScannerViewModel())
}
