//
//  SelectionService.swift
//  InventoryManager
//
//  Created by Milan Parađina on 14.08.2025..
//

import Foundation
import SwiftUI
import CoreData

@MainActor
final class SelectionService: ObservableObject {
    // google
    @AppStorage(UserDefaultsConstants.isUserFirstTime) private var isUserFirstTime: Bool?
    
    // sheets
    @AppStorage(UserDefaultsConstants.selectedSpreadsheetId) private var selectedSpreadsheetId: String?
    @AppStorage(UserDefaultsConstants.selectedSheetId) private var selectedSheetId: String?

    let context: NSManagedObjectContext
    
    init(dbService: DatabaseService) {
        self.context = dbService.container.viewContext
    }
    
    func setSheetSelectecion(_ spreadsheetId: String, _ sheetId: String) {
        selectedSpreadsheetId = spreadsheetId
        selectedSheetId = sheetId
    }
    
    func clearSheetSelection() {
        selectedSpreadsheetId = nil
        selectedSheetId = nil
    }
    
    func getSelectedSpreadsheet() -> Spreadsheet? {
        guard let spreadsheetId = selectedSpreadsheetId else { return nil }
        let request: NSFetchRequest<Spreadsheet> = Spreadsheet.fetchRequest()
        request.predicate = NSPredicate(format: "spreadsheetId == %@", spreadsheetId)
        request.fetchLimit = 1
        return try? context.fetch(request).first
    }
    
    func getSelectedSheet() -> Sheet? {
        guard let spreadsheetId = selectedSpreadsheetId,
        let sheetId = selectedSheetId else { return nil }
        
        let request: NSFetchRequest<Sheet> = Sheet.fetchRequest()
        request.predicate = NSPredicate(format: "name == %@ AND spreadsheet.spreadsheetId == %@", sheetId, spreadsheetId)
        request.fetchLimit = 1
        
        return try? context.fetch(request).first
    }
    
    func validateSelection() {
        if getSelectedSpreadsheet() == nil {
            clearSheetSelection()
        } else if selectedSheetId != nil && getSelectedSheet() == nil {
            selectedSheetId = nil
        }
    }
    
}
