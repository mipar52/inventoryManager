//
//  SelectionProvider.swift
//  InventoryManager
//
//  Created by Milan Parađina on 14.08.2025..
//

import Foundation

protocol SelectionProvider {
    var sheetId: String { get }
    var spreadsheetId: String { get }
    
    func setSelection(spreadsheetId: String, sheetId: String)
    func getSelection() -> (String, String)
}
