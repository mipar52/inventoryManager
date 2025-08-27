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
    let qrCodeSettingsService: QrCodeSettingsStoreService
    
    init(db: DatabaseService, qrCodeSettingsService: QrCodeSettingsStoreService = QrCodeSettingsStoreService()) {
        self.db = db
        self.qrCodeSettingsService = qrCodeSettingsService
    }
    
    func configure() async throws {
        try await sheetService.configure()
    }
    
    func sendAllScans(items: [QRCodeData]) async throws {
        for item in items {
            if let text = item.stringData {
                try await sheetService.appendDataToSheet(
                    qrCodeData: text.components(separatedBy: qrCodeSettingsService.qrCodeDelimiter ?? ""),
                    qrDelimiter: qrCodeSettingsService.qrCodeDelimiter,
                    qrCodeWord: qrCodeSettingsService.qrAcceptanceText
                )
            }
        }
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
