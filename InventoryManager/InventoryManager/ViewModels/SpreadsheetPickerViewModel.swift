//
//  SpreadsheetPickerViewModel.swift
//  InventoryManager
//
//  Created by Milan Parađina on 14.08.2025..
//

import Foundation

@MainActor
final class SpreadsheetPickerViewModel: ObservableObject {
    private let selectionService: SelectionService
    
    @Published var selectedSpreadsheet: Spreadsheet?
    @Published var selectedSheet: Sheet?
    @Published var selectionString: String = "Spreadsheet not selected yet"
    
    init(selectionService: SelectionService) {
        self.selectionService = selectionService
    }
    
    func loadSelection() {
        selectedSpreadsheet = selectionService.getSelectedSpreadsheet()
        selectedSheet = selectionService.getSelectedSheet()
        if let spreadsheetName = selectedSpreadsheet?.name,
           let sheetName = selectedSheet?.name {
            selectionString = "\(spreadsheetName) - \(sheetName)"
        }
    }
    
    func setSelection(with spreadsheet: String, sheet: String) {
        self.selectionService.setSelectecion(spreadsheet, sheet)
        loadSelection()
        debugPrint("Selected: \(selectionString)")
    }
}
