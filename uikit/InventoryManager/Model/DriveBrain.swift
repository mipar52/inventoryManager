//
//  DriveBrain.swift
//  InventoryManager
//
//  Created by Milan Parađina on 14.11.2021..
//

import Foundation
import GoogleAPIClientForREST
import GoogleSignIn


class DriveBrain {
    
    let driveService = GTLRDriveService()
    let sheetBrain = SheetBrain()
    let database = DataBaseBrain()
    
    func findDriveSheets (completionHandler: @escaping (Bool, Int?) -> Void) {
        let database = DataBaseBrain()
        driveService.apiKey = K.keys.apiKey
        driveService.authorizer = GIDSignIn.sharedInstance.currentUser?.authentication.fetcherAuthorizer()
        
        let query = GTLRDriveQuery_FilesList.query()
        //mimeType='application/vnd.google-apps.spreadsheet'  mimeType='application/vnd.google-apps.folder'
        query.q = "mimeType='application/vnd.google-apps.spreadsheet' and trashed=false"
        var driveSheetNumber = 0
        driveService.executeQuery(query, completionHandler: { [self] ticket, files, error in
            if error == nil {
                let list = files as! GTLRDrive_FileList
                let listFiles = list.files
                DispatchQueue.global(qos: .background).async {
                let group = DispatchGroup()
                if let InventoryManager = listFiles {
                    for item in InventoryManager {
                        group.enter()
                        let name : String = item.name!
                        let id: String = item.identifier!
                        database.fetchExistingSpreadsheet(spreadsheetId: id) { isDuplicated in
                            if isDuplicated == false {
                                print(item)
                                driveSheetNumber += 1
                                print("Feting sheets as well..")
                                sheetBrain.getSheetsFromSpreadsheets(sheetName: name, spreadsheetId: id)
                                database.savePassedData()
                            }
                        }
                        group.leave()
                        }
                    }
                    group.wait()
                    DispatchQueue.main.async {
                        completionHandler(true, driveSheetNumber)
                      }
                }
            } else {
                if let error = error {
                    completionHandler(false, nil)
                    print("An error occurred: \(error)")
                }
            }
        })
    }
}
