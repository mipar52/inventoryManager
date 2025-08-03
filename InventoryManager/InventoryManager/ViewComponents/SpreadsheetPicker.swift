//
//  SpreadsheetPicker.swift
//  InventoryManager
//
//  Created by Milan Parađina on 03.08.2025..
//

import SwiftUI

struct SpreadsheetPicker: View {
    @ObservedObject var viewModel: ScannerViewModel
    var body: some View {
        Picker(selection: $viewModel.selectedSpreadsheet) {
            ForEach(viewModel.spreadsheets ?? [], id: \.id) { sheet in
                Text(sheet.name).tag(sheet as GoogleSpreadsheet?)
            }
        } label: {
            Text("Select Spreadsheet")
                .scaledToFit()
        }
        .onSubmit {
            viewModel.startScanningSession()
        }
        .onTapGesture {
            viewModel.stopScanningSession()
        }
        .pickerStyle(.automatic)
        .frame(width: 200, height: 50)
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

#Preview {
    SpreadsheetPicker(viewModel: ScannerViewModel())
}
