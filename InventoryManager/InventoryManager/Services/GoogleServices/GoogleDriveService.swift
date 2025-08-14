//
//  GoogleDriveService.swift
//  InventoryManager
//
//  Created by Milan Parađina on 03.08.2025..
//

import Foundation
import GoogleAPIClientForREST_Drive
import GoogleAPIClientForREST_Sheets


final class GoogleDriveService {
    private let db: DatabaseService
    private var driveService: GTLRDriveService?
    private var spreadsheetService = GoogleSpreadsheetService()
    
    init(db: DatabaseService) {
        self.db = db
    }
    
    func configure() async throws {
        do {
            self.driveService = try await GoogleAuthManager.shared.restoreTokenIfNeeded(GTLRDriveService.self)
            try await self.spreadsheetService.configure()
        } catch {
            debugPrint("[GoogleDriveService] - Error initializing Google Sheets service: \(error)")
        }
    }
    
    func retriveSpreadsheetsFromDrive(progress: @MainActor @escaping (String) -> Void) async throws {
        guard let driveService = self.driveService else { throw GoogleAuthError.ServiceUnavailable }
        
        let query = GTLRDriveQuery_FilesList.query()
        query.q = "mimeType='application/vnd.google-apps.spreadsheet' and trashed=false"
       
        return try await withCheckedThrowingContinuation { [weak self] continuation in
            driveService.executeQuery(query, completionHandler: { ticket, files, error in
                if error == nil {
                    guard let list = files as? GTLRDrive_FileList,
                          let listFiles = list.files else {
                        continuation.resume(throwing: GoogleAuthError.ServiceUnavailable)
                        return
                    }

                    Task {
                        var googleSpreadsheets = [GoogleSpreadsheet]()
                        for item in listFiles {
                            if let name = item.name,
                               let id = item.identifier,
                               let sheets = try await self?.spreadsheetService.getSheetsFromSpreadsheet(from: id) {
                                await progress(name)
                                googleSpreadsheets.append(GoogleSpreadsheet(id: id, name: name, sheets: sheets))
                            }
                        }
                        continuation.resume()
                        try await self?.db.createSpreadsheetsWithSheets(googleSpreadsheets)
                        
                    }
                } else {
                    if let error = error {
                        continuation.resume(throwing: error)
                        debugPrint("[GoogleDriveService] - Error getting Google Sheets service: \(error)")
                    }
                }
            })
        }
    }
    
//    func createNewSpreadsheet(with name: String) async throws {
//        print("Creating New Sheet ...\n")
//        
//        let newSheet = GTLRSheets_Spreadsheet.init()
//        let properties = GTLRSheets_SpreadsheetProperties.init()
//        properties.title = name
//        newSheet.properties = properties
//        
//        let query = GTLRSheetsQuery_SpreadsheetsCreate.query(withObject:newSheet)
//        query.fields = "spreadsheetId"
//        
//        query.completionBlock = { (ticket, result, error) in
//            // let sheet = result as? GTLRSheets_Spreadsheet
//            if let error = error {
//                completionHandler("Error:\n\(error.localizedDescription)")
//                print("Error in creating the Sheet: \(error)")
//                return
//                
//            }
//            else {
//                let response = result as! GTLRSheets_Spreadsheet
//                let identifier = response.spreadsheetId
//                print("Spreadsheet id: \(String(describing: identifier))")
//                
//                completionHandler("Success!\nCreated a new Spreadsheet with name: \(String(describing: properties.title)) and ID: \(String(describing: identifier))")
//            }
//        }
//        sheetsService.executeQuery(query, completionHandler: nil)
//    }
//    
//    func createNewSheet(completionHandler: @escaping (String) -> Void) {
//        
//        let batchUpdate = GTLRSheets_BatchUpdateSpreadsheetRequest.init()
//        let request = GTLRSheets_Request.init()
//        
//        let properties = GTLRSheets_SheetProperties.init()
//        properties.title = "New testing sheet"
//        
//        let sheetRequest = GTLRSheets_AddSheetRequest.init()
//        sheetRequest.properties = properties
//        
//        request.addSheet = sheetRequest
//        
//        batchUpdate.requests = [request]
//        
//        let createQuery = GTLRSheetsQuery_SpreadsheetsBatchUpdate.query(withObject: batchUpdate, spreadsheetId: Constants.sheetID)
//        
//        sheetsService.executeQuery(createQuery) { (ticket, result, err) in
//            if let error = err {
//                print(error)
//                completionHandler("Error with creating sheet:\(error.localizedDescription)")
//            } else {
//                completionHandler("Success! Added new sheet!")
//                print("Sheet added!")
//            }
//        }
//    }
}

