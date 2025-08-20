//
//  ScanDetailsViewModel.swift
//  InventoryManager
//
//  Created by Milan Parađina on 20.08.2025..
//

import Foundation

@MainActor
final class ScanDetailsViewModel: ObservableObject {
    private let sheetService: GoogleSpreadsheetService
    private let db: DatabaseService
    
    init(sheetService: GoogleSpreadsheetService, db: DatabaseService) {
        self.sheetService = sheetService
        self.db = db
    }
    
    func sendItem(item: QRCodeData) async throws {
        if let qrCodeData = item.stringData {
            try await sheetService.appendDataToSheet(qrCodeData: qrCodeData)
        }
    }
    
    func deleteItem(item: QRCodeData) async throws {
        if let timestamp = item.timestamp {
            try db.deleteQrCodeData(timestamp: timestamp)
        }
    }
}
