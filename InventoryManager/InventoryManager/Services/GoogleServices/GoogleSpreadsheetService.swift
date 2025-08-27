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
    
    func appendDataToSheet(qrCodeData: [String], qrDelimiter: String?, qrCodeWord: String?) async throws {
        guard let sheetsService = sheetsService else { throw GoogleAuthError.NotSignedIn}
        guard let spreadsheetId = UserDefaults.standard.string(forKey: UserDefaultsConstants.selectedSpreadsheetId),
        let sheetId = UserDefaults.standard.string(forKey: UserDefaultsConstants.selectedSheetId) else
        { throw GoogleServiceError.serviceUnavailable }
        
        
        let range = "\(sheetId)!A1:Q"
        let rangeToAppend = GTLRSheets_ValueRange.init();
        if let qrCodeWord = qrCodeWord {
            if qrCodeData.contains(qrCodeData) {
                throw QrError.invalidQr(message: "Invalid QR code! Only QR codes containing word '\(qrCodeWord)' can be added to the spreadsheet!")
            }
        }
        rangeToAppend.values = [qrCodeData]
        
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
    
    func sendBatchUpdateToSheet(items: [QRCodeData]) async throws {
        guard let sheetsService = sheetsService else { throw GoogleAuthError.NotSignedIn}
        guard let spreadsheetId = UserDefaults.standard.string(forKey: UserDefaultsConstants.selectedSpreadsheetId),
        let sheetId = UserDefaults.standard.string(forKey: UserDefaultsConstants.selectedSheetId) else
        { throw GoogleAuthError.ServiceUnavailable }
        
        
        let range = "\(sheetId)!A1:Q"
        let rangeToAppend = GTLRSheets_ValueRange.init();
        let request = GTLRSheets_BatchUpdateSpreadsheetRequest()
        let itemArray = items.map { $0.stringData?.components(separatedBy: "\n") }
        request.responseRanges = ["bla", "test"]
        //rangeToAppend.values = [itemscomponents(separatedBy: " ")]
        let query = GTLRSheetsQuery_SpreadsheetsBatchUpdate.query(withObject: request, spreadsheetId: spreadsheetId)
        
        return try await withCheckedThrowingContinuation { continuation in
            sheetsService.executeQuery(query) { (ticket, result, error) in
                    if let error = error {
                        debugPrint("[GoogleSpreadsheetService] - Error in appending data: \(error)")
                        continuation.resume(throwing: error)
                    } else {
                        debugPrint("[GoogleSpreadsheetService] - data sent: \(items.count) to SheetID: \(spreadsheetId)")
                        continuation.resume()
                    }
                }
            }
    }
    
    func getSheetsFromSpreadsheet(from spreadsheetId: String) async throws -> [GoogleSheet] {
        guard let sheetsService = sheetsService else {
            throw GoogleAuthError.NotSignedIn
        }

        let query = GTLRSheetsQuery_SpreadsheetsGet.query(withSpreadsheetId: spreadsheetId)

        return try await withCheckedThrowingContinuation { continuation in
            sheetsService.executeQuery(query) { (ticket, result, error) in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }

                guard let result = result as? GTLRSheets_Spreadsheet,
                      let sheets = result.sheets else {
                    continuation.resume(throwing: GoogleAuthError.ServiceUnavailable)
                    return
                }

                debugPrint("[GoogleSpreadsheetService] - Found \(sheets.count) sheets in spreadsheet: \(spreadsheetId)")

                let sheetModels = sheets.compactMap {
                    GoogleSheet(
                        id: $0.properties?.sheetId?.stringValue ?? "",
                        name: $0.properties?.title ?? ""
                    )
                }

                continuation.resume(returning: sheetModels)
            }
        }
    }

    }

