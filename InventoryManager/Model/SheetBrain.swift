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
import Toast_Swift

class SheetBrain: NSObject, GIDSignInDelegate  {

//    var dataArray = [ScannedData]()
    //inScan iOS Sheet -> https://docs.google.com/spreadsheets/d/1Pr07hswTQGl7olCVzidG_6tnHnKCXjcltTs_8UPsysE/edit#gid=0
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    let defaults = UserDefaults.standard

    
    let scopes = [kGTLRAuthScopeSheetsSpreadsheets]
    let driveScopes = [kGTLRAuthScopeSheetsDrive]
    private let combinedScopes = [kGTLRAuthScopeSheetsSpreadsheets, kGTLRAuthScopeSheetsDrive]
    let service = GTLRSheetsService()
    let driveService = GTLRDriveService()
    
    var spreadsheets = [Spreadsheet]()
    var sheets = [Sheet]()
    var passedSpreadsheetId : String?
    var passedId : String?
    var passedSheetName: String?
    var dataSuccess : Bool?
    var spreadsheetSucess : Bool?
    var sheetSuccess: Bool?
    var createSuccess: Bool?
    var updateSuccess: Bool?
    var didNotSend: Bool?
    var isURLvalid: Bool?
    var savedSheetId: String?
    var isSheetDuplicated: Bool?
    var currentRowLocation: String?
    var existingSheetSuccess: Bool?
    let defaultSheetId = "1bRmLdawOufumtqaw24tjoKluBXYTY64aHGEjlsZRy8M"
    var driveSheetNumber = 0
    var newSheetCounter = 0
    var addedspreadsheetName : String?
    var addedSpreadsheetId : String?
    
    func showSheetName(VC: UINavigationController?) {
        passedSheetName = defaults.object(forKey: "sheetBrainName") as? String ?? "defaultSheetId"
        var style = ToastStyle()
        style.backgroundColor = #colorLiteral(red: 0.5843137503, green: 0.8235294223, blue: 0.4196078479, alpha: 1)
        style.messageColor = .black
        style.messageAlignment = .center
        VC?.view.makeToast("Current selected Spreadsheet is \n\(passedSheetName!)", duration: 2.0, position: .bottom, style: style)
    }
    
    func showSheetNameToVc(VC: UIViewController?, position: ToastPosition ) {
        passedSheetName = defaults.object(forKey: "sheetBrainName") as? String ?? defaultSheetId
        var style = ToastStyle()
        style.backgroundColor = #colorLiteral(red: 0.5843137503, green: 0.8235294223, blue: 0.4196078479, alpha: 1)
        style.messageColor = .black
        style.messageAlignment = .center
        VC?.view.makeToast("Current selected Spreadsheet is \n\(passedSheetName!)", duration: 2.0, position: position, style: style)
    }
    
    func sendDataToSheet(results: Array<[Any]>.ArrayLiteralElement, failedData: String?, completionHandler: @escaping (Bool) -> Void) {
        
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().scopes = combinedScopes
        GIDSignIn.sharedInstance()?.signInSilently()

        if passedSpreadsheetId != nil {
        print("Passed shee is not nil: \(String(describing: passedSpreadsheetId)) U SheetBrain")
        defaults.set(passedSpreadsheetId, forKey: "lastSheetId")
            }

            let saveSheet : String? = defaults.object(forKey: "sheetBrainId") as? String ?? "Inventura 2020"
            let sheetId : String? = defaults.object(forKey: "passedSheetId") as? String ?? "A1:Q"
            if passedSpreadsheetId == nil && saveSheet == nil {
                passedSpreadsheetId = defaultSheetId
            } else if passedSpreadsheetId == nil && saveSheet != nil {
                passedSpreadsheetId = saveSheet
            }
        
        if passedId == nil && sheetId == nil {
            passedId = ""
        } else if passedId == nil && sheetId != nil {
            passedId = sheetId
        }
        
        let spreadsheetId = passedSpreadsheetId!
        let range = "\(passedId!)!A1:Q"
        let rangeToAppend = GTLRSheets_ValueRange.init();
        
        rangeToAppend.values = [results]
        
        let query = GTLRSheetsQuery_SpreadsheetsValuesAppend.query(withObject: rangeToAppend, spreadsheetId: spreadsheetId, range: range)

            query.valueInputOption = "USER_ENTERED"

        service.executeQuery(query) { (ticket, result, error) in

                if let error = error {
                    self.dataSuccess = false
                    print("Error in appending data: \(error)")
                    
                    if failedData != nil {
                    var savedData = [ScannedData]()
                                            
                    let dataToSave = ScannedData(context: self.context)
                    dataToSave.scannedData = failedData
                    print("Failed data that is going to db: \(String(describing: dataToSave.scannedData))")
                    
                    savedData.append(dataToSave)
                    let dbBrain = DataBaseBrain()
                    dbBrain.savePassedData()
                    }
                    completionHandler(self.dataSuccess!)
               
                } else {
                    print("Data sent: \(results)")
                    self.dataSuccess = true
                    completionHandler(self.dataSuccess!)
                }
            }
        }
    
    func sendMulitpleRequests(results: Array<Any>.ArrayLiteralElement, completionHandler: @escaping (Bool) -> Void) {
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().scopes = combinedScopes
        GIDSignIn.sharedInstance()?.signInSilently()
        
        if passedSpreadsheetId != nil {
        print("Passed shee is not nil: \(String(describing: passedSpreadsheetId)) U SheetBrain")
        defaults.set(passedSpreadsheetId, forKey: "lastSheetId")
            }

            let saveSheet : String? = defaults.object(forKey: "sheetBrainId") as? String ?? "Inventura 2020"
            let sheetId : String? = defaults.object(forKey: "passedSheetId") as? String ?? "A1:Q"
            if passedSpreadsheetId == nil && saveSheet == nil {
                passedSpreadsheetId = defaultSheetId
            } else if passedSpreadsheetId == nil && saveSheet != nil {
                passedSpreadsheetId = saveSheet
            }
        
        if passedId == nil && sheetId == nil {
            passedId = ""
        } else if passedId == nil && sheetId != nil {
            passedId = sheetId
        }
        let spreadsheetId = passedSpreadsheetId!
        let range = "\(passedId!)!A1:Q"
        let rangeToAppend = GTLRSheets_ValueRange.init();

        rangeToAppend.values = results as! [[Any]]
        
        let query = GTLRSheetsQuery_SpreadsheetsValuesAppend.query(withObject: rangeToAppend, spreadsheetId: spreadsheetId, range: range)
            query.valueInputOption = "USER_ENTERED"
        
            service.executeQuery(query) { (ticket, result, error) in

                if let error = error {
                    self.dataSuccess = false
                    print("Error in sending data: \(error)")
                    completionHandler(self.dataSuccess!)
                } else {
                    print("Data sent: \(results)")
                    self.dataSuccess = true
                    completionHandler(self.dataSuccess!)
                }
            }
    }
    
    func createNewSpreadsheet(sheetName: String, completionHandler: @escaping (Bool) -> Void) {
        print("Creating New Sheet ...\n")

        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().scopes = combinedScopes
        GIDSignIn.sharedInstance()?.signInSilently()
        
            let newSheet = GTLRSheets_Spreadsheet.init()
                 let properties = GTLRSheets_SpreadsheetProperties.init()
                  properties.title = sheetName
                  newSheet.properties = properties

                  let query = GTLRSheetsQuery_SpreadsheetsCreate.query(withObject:newSheet)
                  query.fields = "spreadsheetId"

                  query.completionBlock = { (ticket, result, error) in
                      if let error = error {
                        self.sheetSuccess = false
                        completionHandler(self.sheetSuccess!)
                        print("Error in creating the Sheet: \(error)")
                        return
                      }
                      else {
                        DispatchQueue.global(qos: .background).async {
                            let group = DispatchGroup()
                            group.enter()
                            let response = result as! GTLRSheets_Spreadsheet
                            let identifier = response.spreadsheetId
                            self.savedSheetId = identifier
                            
                            self.loadSheetsForSpread(ime: sheetName, spreadID: identifier!)
                            print("Finding sheets in your new Spreadsheet...")
                            group.leave()
                            group.wait()
                        }
                        DispatchQueue.main.async {
                        self.sheetSuccess = true
                        completionHandler(self.sheetSuccess!)
                        }
                      }
                  }
                service.executeQuery(query, completionHandler: nil)
               }

    func findSpreadNameAndSheets(id: String, completionHandler: @escaping (Bool) -> Void ) {
        print("func findSpreadNameAndSheets executing...")
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().scopes = combinedScopes
        GIDSignIn.sharedInstance()?.signInSilently()
        
        let database = DataBaseBrain()
        
        let spreadsheetId = id
        let query = GTLRSheetsQuery_SpreadsheetsGet.query(withSpreadsheetId: spreadsheetId)
        
        service.executeQuery(query) { (ticket, result, error) in
            if let error = error {
                print("Error in the func loadSheets: \(error)")
                self.existingSheetSuccess = false
                completionHandler(self.existingSheetSuccess!)
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
                            print("Added new sheet! Stats: \(existingSpreadsheet.spreadsheetName), with id: \(existingSpreadsheet.spreadsheetId)")
                            group.leave()
                        }
                    }
                    group.wait()
                    database.savePassedData()
                }
                self.existingSheetSuccess = true
                
                DispatchQueue.main.async {
                    completionHandler(self.existingSheetSuccess!)
                }
            }
        }
    }
    
    func findDriveSheets (completionHandler: @escaping (Bool) -> Void) {
        
        let database = DataBaseBrain()
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().scopes = combinedScopes
        GIDSignIn.sharedInstance()?.signInSilently()
        
        let query = GTLRDriveQuery_FilesList.query()
        //mimeType='application/vnd.google-apps.spreadsheet'  mimeType='application/vnd.google-apps.folder'
        query.q = "mimeType='application/vnd.google-apps.spreadsheet' and trashed=false"

        driveService.executeQuery(query, completionHandler: { [self] ticket, files, error in
            if error == nil {
                spreadsheetSucess = true
                let list = files as! GTLRDrive_FileList
                
                let listFiles = list.files
                DispatchQueue.global(qos: .background).async {
                let group = DispatchGroup()
                if let InventoryManager = listFiles {
                    for item in InventoryManager {
                        group.enter()
                        let name : String = item.name!
                        let id: String = item.identifier!
                        database.fetchExistingSpreadsheet(spreadsheetId: id)
                        if database.isSheetDuplicated == true {
                            print("Duplicated")
                            } else if database.isSheetDuplicated == false {
                                print(item)
                                driveSheetNumber += 1
                                print("Feting sheets as well..")
                            
                                self.loadSheetsForSpread(ime: name, spreadID: id)
                                    database.savePassedData()
                            }
                        group.leave()
                        }
                    }
                    group.wait()

                    DispatchQueue.main.async {
                        completionHandler(spreadsheetSucess!)
                      }
                }
            } else {
                if let error = error {
                    spreadsheetSucess = false
                    completionHandler(spreadsheetSucess!)
                    print("An error occurred: \(error)")
                }
            }
        })
    }
    
    func loadSheetsForSpread(ime: String, spreadID: String) {

        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().scopes = combinedScopes
        GIDSignIn.sharedInstance()?.signInSilently()
        let database = DataBaseBrain()
        let spreadsheetId = spreadID
        let query = GTLRSheetsQuery_SpreadsheetsGet.query(withSpreadsheetId: spreadsheetId)
        let driveSpreadsheet = Spreadsheet(context: database.context)
        driveSpreadsheet.spreadsheetName = ime
        driveSpreadsheet.spreadsheetId = spreadID
        service.executeQuery(query) { (ticket, result, error) in
            if let error = error {
                print("Error in the func loadSheets: \(error)")
            } else {
                
                let spread = result as? GTLRSheets_Spreadsheet
                let sheetsFromspreadsheet  = spread?.sheets
 
                    if let sheetInfo = sheetsFromspreadsheet {
                        for info in sheetInfo {
                        let newSheet = Sheet(context: database.context)
                            
                        newSheet.sheetName = info.properties?.title
                        newSheet.sheetId = info.properties?.sheetId?.stringValue
                        newSheet.parentCategory = driveSpreadsheet
                   
                        self.sheets.append(newSheet)
                        print("New Spreadsheet added!:\(String(describing: driveSpreadsheet.spreadsheetName)), SpreadID: \(driveSpreadsheet.spreadsheetId), sheet: \(newSheet.sheetName)")
                    }
                }
            }
        }
        self.spreadsheets.append(driveSpreadsheet)
        database.savePassedData()
    }
    
    func createNewSheet(spreadsheet: Spreadsheet, spreadID: String, sheetName: String, completionHandler: @escaping (Bool) -> Void) {
        
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().scopes = combinedScopes
        GIDSignIn.sharedInstance()?.signInSilently()
        
        let db = DataBaseBrain()
        
        let batchUpdate = GTLRSheets_BatchUpdateSpreadsheetRequest.init()
        let request = GTLRSheets_Request.init()
        let properties = GTLRSheets_SheetProperties.init()
        properties.title = sheetName
        
        let sheetRequest = GTLRSheets_AddSheetRequest.init()
        sheetRequest.properties = properties
        request.addSheet = sheetRequest
        batchUpdate.requests = [request]
        
        let createQuery = GTLRSheetsQuery_SpreadsheetsBatchUpdate.query(withObject: batchUpdate, spreadsheetId: spreadID)
        service.executeQuery(createQuery) { (ticket, result, err) in
            if let error = err {
                print(error)
                self.createSuccess = false
                completionHandler(self.createSuccess!)
            } else {
                self.createSuccess = true
                let newSheet = Sheet(context: db.context)
                newSheet.sheetName = sheetName
                newSheet.parentCategory = spreadsheet
                self.sheets.append(newSheet)
                completionHandler(self.createSuccess!)
                print("Sheet added!")
            }
        }
    }
    
    func updateSheets(spreadsheet: Spreadsheet, spreadID: String, updateArray: [Sheet], completionHandler: @escaping (Bool) -> Void) {
        
        print("func updateSheets executing...")
        
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().scopes = combinedScopes
        GIDSignIn.sharedInstance()?.signInSilently()
        
        let database = DataBaseBrain()
        let query = GTLRSheetsQuery_SpreadsheetsGet.query(withSpreadsheetId: spreadID)
        
        service.executeQuery(query) { (ticket, result, error) in
            if let error = error {
                print("Error in the func loadSheets: \(error)")
                self.updateSuccess = false
                completionHandler(self.updateSuccess!)
                
            } else {
                let result = result as? GTLRSheets_Spreadsheet
                let sheets = result?.sheets
                let group = DispatchGroup()
                    
                    if let sheetInfo = sheets {
                        for info in sheetInfo {
                            group.enter()
                            database.loadSheets(sheetName:  (info.properties?.title)!, sheetId: (info.properties?.sheetId!.stringValue)!, spreadSheet: spreadsheet)
                           
                            print("konacan broj novih sheetova: \(self.newSheetCounter)")
                group.leave()
                }
                group.wait()
                    }

                DispatchQueue.main.async {
                self.newSheetCounter = database.newSheetCounter
                print("Loop sheets: \(self.newSheetCounter)")
                self.updateSuccess = true
                completionHandler(self.updateSuccess!)
                }
            }
        }
    }
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!,
                  withError error: Error!) {
            if let error = error {
                print("Error: \(error)")
                self.service.authorizer = nil
                self.driveService.authorizer = nil
            } else {
                self.service.authorizer = user.authentication.fetcherAuthorizer()
                self.driveService.authorizer = user.authentication.fetcherAuthorizer()
            }
        }
    }
