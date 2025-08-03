//
//  GoogleSpreadsheetService.swift
//  InventoryManager
//
//  Created by Milan Parađina on 03.08.2025..
//

import Foundation
import GoogleAPIClientForREST_Sheets

actor GoogleSpreadsheetService {
    private(set) var sheetsService: GTLRSheetsService?
    
    func configure() async throws {
        do {
            self.sheetsService = try await GoogleAuthManager.shared.restoreTokenIfNeeded(GTLRSheetsService.self)
        } catch {
            debugPrint("[GoogleSpreadsheetService] - Error initializing Google Sheets service: \(error)")
        }
    }
    
    func appendDataToSheet(qrCodeData: String) async throws {
        guard let sheetsService = sheetsService else { throw GoogleAuthError.NotSignedIn}
        
        let spreadsheetId = UserDefaultsConstants.sheetID
        let range = "A1:Q"
        let rangeToAppend = GTLRSheets_ValueRange.init();
        
        rangeToAppend.values = [qrCodeData.components(separatedBy: " ")]
        
        let query = GTLRSheetsQuery_SpreadsheetsValuesAppend.query(withObject: rangeToAppend, spreadsheetId: spreadsheetId, range: range)
            query.valueInputOption = "USER_ENTERED"
        
        return try await withCheckedThrowingContinuation { continuation in
            sheetsService.executeQuery(query) { (ticket, result, error) in
                    if let error = error {
                        debugPrint("[GoogleSpreadsheetService] - Error in appending data: \(error)")
                        continuation.resume(throwing: error)
                    } else {
                        debugPrint("[GoogleSpreadsheetService] - data sent: \(qrCodeData) to SheetID: \(spreadsheetId)")
                        continuation.resume()
                    }
                }
            }
        }
}
