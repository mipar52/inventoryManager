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
    private let qrCodeSettingsService: QrCodeSettingsStoreService
    let item: QRCodeData
    
    @Published var qrStringData: [String]?
    
    init(qrCodeData: QRCodeData,
        sheetService: GoogleSpreadsheetService,
        db: DatabaseService,
        qrCodeSettingsService: QrCodeSettingsStoreService = QrCodeSettingsStoreService()
    ) {
        self.sheetService = sheetService
        self.db = db
        self.qrCodeSettingsService = qrCodeSettingsService
        self.item = qrCodeData
        self.qrStringData = self.item.stringData?.components(separatedBy: qrCodeSettingsService.qrCodeDelimiter ?? "")
    }
    
    func sendItem() async throws {
        if let qrCodeData = item.stringData {
            try await sheetService.appendDataToSheet(
                qrCodeData: qrCodeData.components(separatedBy: qrCodeSettingsService.qrCodeDelimiter ?? "")
            )
        }
    }
    
    func deleteItem() async throws {
        if let timestamp = item.timestamp {
            try db.deleteQrCodeData(timestamp: timestamp)
        }
    }
}
