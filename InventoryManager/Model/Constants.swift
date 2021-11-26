//
//  Constants.swift
//  InventoryManager
//
//  Created by Milan Parađina on 12.11.2021..
//

import Foundation
import UIKit

public struct K {
    
    public struct keys {
        static let clientID = "4678728265-7supi88fufo3v8a90rvmt09098113a1c.apps.googleusercontent.com"
        static let apiKey = "AIzaSyBp2ME20lndkAlBGInV6PaKEFi3nmxH3T8"
        //com.mipar.inventoryManager
        static let microblinkKey = "your-Microblink-license-key"
    }
    public struct scopes {
        static let grantedScopes = "https://www.googleapis.com/auth/spreadsheets"
        static let additionalScopes = ["https://www.googleapis.com/auth/spreadsheets",
                                       "https://www.googleapis.com/auth/drive",
                                       "https://www.googleapis.com/auth/drive.file"]
    }
    public struct uDefaults {
        static let toastSheetName = "toastSheetName"
        static let spreadsheetId = "spreadsheetId"
        static let sheetName = "sheetName"
        static let isuploadAuto = "isuploadAuto"
        static let isScanContinue = "isScanContinue"
        static let sheetSelected = "sheetSelected"
        static let scSwitchisOn = "scSwitchisOn"
        static let aUploadisOn = "aUploadisOn"
    }
    public struct identifiers {
        static let cell = "Cell"
        static let sheetCell = "sheetCell"
        static let spreadsheetCell = "spreadsheetCell"
    }
    public struct segues {
        static let scanDetails = "goToScanDetails"
        static let sheetDetails = "sheetDetails"
        static let goTosheetDetails = "goToSheetDetails"
        static let sheetList = "goToSheetList"
        static let goToSheets = "goToSheets"
        static let tableViewScanDetails = "tableViewScanDetails"
    }
    public struct accountStrings {
        static let signInString = "Singed in!"
        static let signInIssues = "Error with signing in!\nPlease try again"
        static let signInIssuesCell = "Error with signing in! Tap to try again"
        static let singOutTap = "Tap to sign in"
    }
    
    public struct UIStrings {
        static let spreadsheets = "Spreadsheets"
        static let sheets = "Sheets"
        static let googleDrive = "Check Google Drive for new Spreadsheets"
        static let deleteCell = "Delete all Spreadsheets"
        static let uploadAuto = "Upload automatically"
        static let uploadAutoDetail = "Scan without pop-up alerts"
        static let scanContinue = "Scan continuously"
        static let scanContinueDetail = "Scan without pauses"
        static let histroyControllerTitle = "Scan history"
        static let settingsControllerTitle = "Settings"
    }
    public struct popupStrings {
        public struct toast {
            static let errorDataSave = "Upload failed.\nSaving the data..."
            static let successUpload = "Upload sucessful!"
            static let dissmissed =  "Dissmissed..\nSaving the data.."
            static let sheetUrl = "Spreadsheet URL copied!"
            //static let dissmissed =
        }
        public struct alert {
            static let success = "Success"
            static let error = "Error"
            static let noData = "No data"
            static let yes = "Yes"
            static let no = "No"
            static let create = "Create"
            static let add = "Add"
            static let cancel = "Cancel"
            static let delete = "Delete"
            
            static let dataUploaded = "Data uploaded"
            static let dataDeleted = "Data deleted"
            static let noDataSent = "No data to send!"
            static let complete = "Upload complete!"
            
            static let uploadFailed = "Could not upload items to sheet! \nSee if there is a secure connection to the internet or if you are properly signed into your Google account!"
            static let mbLicenseError = "Can't access the SDK!\nCheck if you've entered the correct license key.."
            static let addSpreads = "Add Spreadsheets"
            static let addSpreadAction = "Import every Spreadsheet (and its Sheets) from your Google Drive?"
            static let firstSpreadsheet = "Plese pick a Spreadsheet for your first upload!"
            static let newSpreadsheet = "Add New Google Spreadsheet"
            static let createNewSpreadsheet = "Create New Spreadsheet"
            static let existingSpreadsheet = "Add existing Spreadsheet"
            static let deleteSpreadsheet = "Delete Spreadsheet"
            static let deleteSpreadsheetAction = "This action will only delete the Spreadsheet from the application, not from your Google Drive"
            static let spreadsheetName = "Spreadsheet name"
            static let enterURL = "Enter Spreadsheet URL"
            static let successCreate = "New Spreadsheet created!"
            static let errorCreateSpreadSheet = "Could not create sheet!\nPlease check your internet connection and if you are properly signed in your Google account!"
            static let duplicateSpreadsheet = "Duplicated spreadsheet!"
            static let duplicateSpreadsheetError = "Sheet with the same URL already added!"
            static let urlError = "Enter a valid URL!"
            static let addedSpread = "Added Spreadsheet to your list!"
            static let spreadAlreadyAdded = "All Spreadsheets already added!"
            static let errorFindSpread = "Could not find sheet!\nPlease check your internet connection and if you are properly signed in your Google account!"
            static let errorGetSpread = "Could not get Spreadsheets! \n1. See if you are connected to the Internet \n2. Check if you are properly signed into your Google Account"
            static let deleteAllDataAction = "Are you sure you want to delete all of your scanned information?"
            static let allDataDeleted = "All information deleted!"
            static let allDataDeleteError = "Could not delete all data!\nTry again later"
            
            static let deleteAllSheetDataAction = "Are you sure you want to delete all of your Spreadsheet and Sheet information?\nThis will only delete the information from the application, but not from your Google Drive"
            static let deleteSheet = "Delete Sheet"
            static let deleteSheetAction = "This action will only delete the Sheet from the application, not from your Google Drive"
            static let updateSheets = "Update existing Sheets"
            static let allSheetsHere = "All Sheets already here!"
            static let addedOneSheet = "Added 1 Sheet!"
            static let sheetName = "Sheet name"
            static let addSheet = "Add Sheet"
            static let createSheet = "Create new Sheet"
            static let newSheetAdded = "New Sheet added!"
            static let errorCreateSheet = "Could not create Sheet! \n1. See if you are connected to the Internet \n2. Check if you are properly signed into your Google Account. \n3. See if you have the right perrmission to edit the Spreadsheet."
            static let errorUpdateSheet = "Could not update Sheets! \n1. See if you are connected to the Internet \n2. Check if you are properly signed into your Google Account. \n3. See if you have the right perrmission to edit the Spreadsheet."
            
            static let errorUploadData = "Could not upload the data!\nTry seeing if you are connected to the interet and properly signed into your Google account!"
            
        }
        public struct spinner {
            static let uploadingItem = "Uploading 1 item.."
            static let creatingSheet = "Creating Sheet.."
            static let gettingSheets = "Getting Sheets.."
            static let findingSheets = "Finding Sheets.."
            static let deletingSheet = "Deleting Sheet.."
            static let deletingSpreadsheet = "Deleting Spreadsheet.."
            static let deletingAllData = "Deleting all data.."
            static let sendingData = "Sending data.."
        }
    }
    public struct colors {
        static let error = UIColor(red: 0.9098039269, green: 0.4784313738, blue: 0.6431372762, alpha: 1)
        static let success = UIColor(red: 0.4, green: 0.8509803922, blue: 0.7882352941, alpha: 1)
        static let neutral = UIColor(#colorLiteral(red: 0.6666666865, green: 0.6666666865, blue: 0.6666666865, alpha: 1))
        static let selected = UIColor(#colorLiteral(red: 0.5843137503, green: 0.8235294223, blue: 0.4196078479, alpha: 1))
    }
}
