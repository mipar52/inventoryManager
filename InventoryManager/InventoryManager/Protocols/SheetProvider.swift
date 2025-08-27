//
//  SheetProvider.swift
//  InventoryManager
//
//  Created by Milan Parađina on 27.08.2025..
//

protocol SheetProvider {
    func getSelectedSpreadsheet() -> Spreadsheet
    func getSelectedSheet() -> Sheet
}
