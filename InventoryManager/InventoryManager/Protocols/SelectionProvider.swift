//
//  SelectionProvider.swift
//  InventoryManager
//
//  Created by Milan Parađina on 14.08.2025..
//

import Foundation

protocol SelectionProvider {
    func getSelectedSpreadsheet() -> Spreadsheet?
    func getSelectedSheet() -> Sheet?
}
