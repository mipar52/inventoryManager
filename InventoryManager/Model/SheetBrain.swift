//
//  SheetBrain.swift
//  InventoryManager
//
//  Created by Milan Parađina on 25.03.2021..
//

import Foundation
import GoogleAPIClientForREST
import GoogleSignIn
import UIKit
import GTMSessionFetcher

class SheetBrain: NSObject {

    let sheetService = GTLRSheetsService()
    let driveService = GTLRDriveService()
    var spreadsheets = [Spreadsheet]()
    var sheets = [Sheet]()
    
    func sendDataToSheet(results: Array<[Any]>.ArrayLiteralElement, failedData: String?, completionHandler: @escaping (Bool) -> Void) {
        let defaults = UserDefaults.standard
        let database = DataBaseBrain()
        let utils = Utils()
        sheetService.apiKey = K.keys.apiKey
        sheetService.authorizer = GIDSignIn.sharedInstance.currentUser?.authentication.fetcherAuthorizer()
        
        let spreadsheetId = defaults.string(forKey: K.uDefaults.spreadsheetId)!
        let sheetName = defaults.string(forKey: K.uDefaults.sheetName)
        let range = "\(sheetName!)!A1:Q"
        let rangeToAppend = GTLRSheets_ValueRange.init();
        
        rangeToAppend.values = [results]
        let query = GTLRSheetsQuery_SpreadsheetsValuesAppend.query(withObject: rangeToAppend, spreadsheetId: spreadsheetId, range: range)
            query.valueInputOption = "USER_ENTERED"
        sheetService.executeQuery(query) { (ticket, result, error) in
                if error != nil {
                if failedData != nil {
                var savedData = [ScannedData]()
                let dataToSave = ScannedData(context: database.context)
                dataToSave.scannedData = failedData
                dataToSave.scanDate = utils.getCurrentDate()
                savedData.append(dataToSave)
                database.savePassedData()
                }
                completionHandler(false)
                } else {
                    print("Data sent: \(results)")
                    completionHandler(true)
                }
            }
        }
    
    func sendMulitpleRequests(results: Array<Any>.ArrayLiteralElement, completionHandler: @escaping (Bool) -> Void) {
        sheetService.apiKey = K.keys.apiKey
        sheetService.authorizer = GIDSignIn.sharedInstance.currentUser?.authentication.fetcherAuthorizer()
        let defaults = UserDefaults.standard
        let spreadsheetId = defaults.string(forKey: K.uDefaults.spreadsheetId)!
        let sheetName = defaults.string(forKey: K.uDefaults.sheetName)
        
        
        let range = "\(sheetName!)!A1:Q"
        let rangeToAppend = GTLRSheets_ValueRange.init()
        rangeToAppend.values = results as? [[Any]]
        let query = GTLRSheetsQuery_SpreadsheetsValuesAppend.query(withObject: rangeToAppend, spreadsheetId: spreadsheetId, range: range)
            query.valueInputOption = "USER_ENTERED"
            sheetService.executeQuery(query) { (ticket, result, error) in
                if let error = error {
                    print("Error in sending data: \(error)")
                    completionHandler(false)
                } else {
                    print("Data sent: \(results)")
                    completionHandler(true)
            }
        }
    }
    
    func createNewSpreadsheet(sheetName: String, completionHandler: @escaping (Bool) -> Void) {
        sheetService.apiKey = K.keys.apiKey
        sheetService.authorizer = GIDSignIn.sharedInstance.currentUser?.authentication.fetcherAuthorizer()
        
        let newSheet = GTLRSheets_Spreadsheet.init()
        let properties = GTLRSheets_SpreadsheetProperties.init()
            properties.title = sheetName
            newSheet.properties = properties

        let query = GTLRSheetsQuery_SpreadsheetsCreate.query(withObject:newSheet)
            query.fields = "spreadsheetId"
            query.completionBlock = { (ticket, result, error) in
                      if let error = error {
                        completionHandler(false)
                        print("Error in creating the Sheet: \(error)")
                        return
                      } else {
                        DispatchQueue.global(qos: .background).async {
                        let group = DispatchGroup()
                            group.enter()
                        let response = result as! GTLRSheets_Spreadsheet
                        let identifier = response.spreadsheetId
                        self.getSheetsFromSpreadsheets(sheetName: sheetName, spreadsheetId: identifier!)
                            group.leave()
                            group.wait()
                        }
                        DispatchQueue.main.async {
                        completionHandler(true)
                    }
                }
            }
        sheetService.executeQuery(query, completionHandler: nil)
    }
    
    func createNewSheet(spreadsheet: Spreadsheet, spreadID: String, sheetName: String, completionHandler: @escaping (Bool) -> Void) {
        sheetService.apiKey = K.keys.apiKey
        sheetService.authorizer = GIDSignIn.sharedInstance.currentUser?.authentication.fetcherAuthorizer()
        let database = DataBaseBrain()

        let batchUpdate = GTLRSheets_BatchUpdateSpreadsheetRequest.init()
        let request = GTLRSheets_Request.init()
        let properties = GTLRSheets_SheetProperties.init()
        properties.title = sheetName
        
        let sheetRequest = GTLRSheets_AddSheetRequest.init()
        sheetRequest.properties = properties
        request.addSheet = sheetRequest
        batchUpdate.requests = [request]
        
        let createQuery = GTLRSheetsQuery_SpreadsheetsBatchUpdate.query(withObject: batchUpdate, spreadsheetId: spreadID)
        sheetService.executeQuery(createQuery) { (ticket, result, err) in
            if let error = err {
                print(error)
                completionHandler(false)
            } else {
                let newSheet = Sheet(context: database.context)
                newSheet.sheetName = sheetName
                newSheet.parentCategory = spreadsheet
                self.sheets.append(newSheet)
                completionHandler(true)
            }
        }
    }

    func findSpreadsheetAndSheets(id: String, completionHandler: @escaping (Bool) -> Void ) {
        sheetService.apiKey = K.keys.apiKey
        sheetService.authorizer = GIDSignIn.sharedInstance.currentUser?.authentication.fetcherAuthorizer()
        let database = DataBaseBrain()

        let spreadsheetId = id
        let query = GTLRSheetsQuery_SpreadsheetsGet.query(withSpreadsheetId: spreadsheetId)
        sheetService.executeQuery(query) { (ticket, result, error) in
            if let error = error {
                print("Error in the func loadSheets: \(error)")
                completionHandler(false)
            } else {
                let result = result as? GTLRSheets_Spreadsheet
                let existingSpreadsheet = Spreadsheet(context: database.context)
                let spreadsheetName = result?.properties?.title
                let spreadsheetId = result?.spreadsheetId
                existingSpreadsheet.spreadsheetName = spreadsheetName
                existingSpreadsheet.spreadsheetId = spreadsheetId
                let sheets = result?.sheets
                DispatchQueue.global(qos: .background).async {
                    let group = DispatchGroup()
                    if let sheetInfo = sheets {
                        for info in sheetInfo {
                            group.enter()
                            let newSheet = Sheet(context: database.context)
                                newSheet.sheetName = info.properties?.title
                                newSheet.sheetId = info.properties?.sheetId?.stringValue
                                newSheet.parentCategory = existingSpreadsheet
                            self.sheets.append(newSheet)
                            group.leave()
                        }
                    }
                    group.wait()
                    database.savePassedData()
                }
                DispatchQueue.main.async {
                    completionHandler(true)
                }
            }
        }
    }
    
    func getSheetsFromSpreadsheets(sheetName: String, spreadsheetId: String) {

        sheetService.apiKey = K.keys.apiKey
        sheetService.authorizer = GIDSignIn.sharedInstance.currentUser?.authentication.fetcherAuthorizer()
        
        let database = DataBaseBrain()
        let spreadsheetId = spreadsheetId
        let query = GTLRSheetsQuery_SpreadsheetsGet.query(withSpreadsheetId: spreadsheetId)
        let driveSpreadsheet = Spreadsheet(context: database.context)
        driveSpreadsheet.spreadsheetName = sheetName
        driveSpreadsheet.spreadsheetId = spreadsheetId
        sheetService.executeQuery(query) { (ticket, result, error) in
            if let error = error {
                print("Error in the func loadSheets: \(error)")
            } else {
                let spreadsheet = result as? GTLRSheets_Spreadsheet
                let sheetsFromSpreadsheet  = spreadsheet?.sheets
                    if let sheetInfo = sheetsFromSpreadsheet {
                        for info in sheetInfo {
                        let newSheet = Sheet(context: database.context)
                        newSheet.sheetName = info.properties?.title
                        newSheet.sheetId = info.properties?.sheetId?.stringValue
                        newSheet.parentCategory = driveSpreadsheet
                        self.sheets.append(newSheet)
                    }
                }
            }
        }
        self.spreadsheets.append(driveSpreadsheet)
        database.savePassedData()
    }
    
    func updateSheets(spreadsheet: Spreadsheet, spreadID: String, completionHandler: @escaping (Bool, Int?) -> Void) {
        sheetService.apiKey = K.keys.apiKey
        sheetService.authorizer = GIDSignIn.sharedInstance.currentUser?.authentication.fetcherAuthorizer()
        let database = DataBaseBrain()
        let query = GTLRSheetsQuery_SpreadsheetsGet.query(withSpreadsheetId: spreadID)
        var sheetCounter = 0
        sheetService.executeQuery(query) { (ticket, result, error) in
            if let error = error {
                print("Error in the func loadSheets: \(error)")
                completionHandler(false, nil)
            } else {
                let result = result as? GTLRSheets_Spreadsheet
                let sheets = result?.sheets
                let group = DispatchGroup()
                if let sheetInfo = sheets {
                   for sheet in sheetInfo {
                       group.enter()
                       database.fetchExistingSheets(sheetName: sheet.properties?.title, sheetId: sheet.properties?.sheetId!.stringValue, spreadSheet: spreadsheet) { isDuplicated, counter in
                           if isDuplicated == false {
                               sheetCounter = sheetCounter + counter
                           }
                       }
                       group.leave()
                   }
                group.wait()
                }
                DispatchQueue.main.async {
                completionHandler(true, sheetCounter)
                }
            }
        }
    }    
}
