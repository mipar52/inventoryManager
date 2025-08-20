//
//  ScanHistoryViewModel.swift
//  InventoryManager
//
//  Created by Milan Parađina on 20.08.2025..
//

import Foundation

@MainActor
final class ScanHistoryViewModel: ObservableObject {
    
    let sheetService: GoogleSpreadsheetService = GoogleSpreadsheetService()
    let db: DatabaseService
    
    init(db: DatabaseService) {
        self.db = db
    }
    
    func configure() async throws {
        try await sheetService.configure()
    }
    
    func sendAllScans(items: [QRCodeData]) async throws {
        try await sheetService.sendBatchUpdateToSheet(items: items)
    }
    func deleteItem(item: QRCodeData) throws {
        if let timestamp = item.timestamp {
            try db.deleteQrCodeData(timestamp: timestamp)
        }
    }
    func deleteAllItems() throws {
        try db.deleteAllQrCodeData()
    }
}
