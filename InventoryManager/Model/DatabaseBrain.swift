//
//  DataBaseBrain.swift
//  InventoryManager
//
//  Created by Milan Parađina on 25.03.2021..
//

import Foundation
import CoreData
import UIKit

class DataBaseBrain {
    var sheetArray = [Spreadsheet]()
    let sheetBrain = SheetBrain()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var isSheetDuplicated: Bool?
    var isDuplicated: Bool?
    var sheets = [Sheet]()
    var newSheetCounter = 0
    var selectedSpreadsheet : Spreadsheet? {
        didSet{
            loadSpreadSheets()
        }
    }
    
    func savePassedData() {
             do {
                 try context.save()
                print("Data saved!")
             } catch {
                 print("Error saving category \(error)")
             }
         }
  func fetchExistingSpreadsheet (spreadsheetId: String) {
      

      
          let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Spreadsheet")
          fetchRequest.fetchLimit =  1
         
          fetchRequest.predicate = NSPredicate(format: "spreadsheetId == [d] %@" ,spreadsheetId)
          fetchRequest.includesPendingChanges = false
      
          do {
              let count = try context.count(for: fetchRequest)
              if count > 0 {
                  //print("count is \(count)")
                isSheetDuplicated = true
              } else {
                isSheetDuplicated = false
              }
          }catch let error as NSError {
              print("Could not fetch. \(error), \(error.userInfo)")
          }
  }
    func loadSheets (sheetName: String?, sheetId: String?, spreadSheet: Spreadsheet) {
        let request: NSFetchRequest<Sheet> = Sheet.fetchRequest()
        request.fetchLimit =  1
        
        let spreadsheetPredicate = NSPredicate(format: "parentCategory == %@", spreadSheet)
        let sheetPredicate = NSPredicate(format: "sheetName == %@" ,sheetName!)
        
        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [spreadsheetPredicate, sheetPredicate])
        request.includesPendingChanges = false
        request.includesSubentities = false
        do {
            let count = try context.count(for: request)
            if count > 0 {
                print("count is \(count)")
              isDuplicated = true
              print("Fetch existing sheet bool: \(isDuplicated), for \(sheetName)")
                return
            } else if count == 0 {
                self.newSheetCounter = self.newSheetCounter + 1
                let newSheet = Sheet(context: context)
                newSheet.sheetName = sheetName
                newSheet.sheetId = sheetId
                newSheet.parentCategory = spreadSheet
                sheets.append(newSheet)
                //self.newSheetCounter += 1
                savePassedData()

              isDuplicated = false
            }
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }

    func fetchExistingSheets(sheetName: String, sheetId: String, spreadSheet: Spreadsheet) {
        let sheetBrain = SheetBrain()
        print("Fetch existing sheet executing...")
        let fetchRequest: NSFetchRequest<Spreadsheet> = Spreadsheet.fetchRequest()

        fetchRequest.fetchLimit =  1
        fetchRequest.predicate = NSPredicate(format: "sheet.sheetName == %@" ,sheetName)
        fetchRequest.includesPendingChanges = false
        fetchRequest.includesSubentities = false
        
        do {
            let count = try context.count(for: fetchRequest)
            if count > 0 {
              isDuplicated = true
              return
                
            } else if count == 0 {
                sheetBrain.newSheetCounter += 1
                let newSheet = Sheet(context: context)
                newSheet.sheetName = sheetName
                newSheet.sheetId = sheetId
                newSheet.parentCategory = spreadSheet
                sheets.append(newSheet)
                savePassedData()
              isDuplicated = false
            }
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        print(newSheetCounter)
    }
    
    func loadSpreadSheets(with request: NSFetchRequest<Spreadsheet> = Spreadsheet.fetchRequest(), predicate: NSPredicate? = nil) {
        
        let categoryPredicate = NSPredicate(format: "parentCategory.spreadsheetName MATCHES %@", selectedSpreadsheet!.spreadsheetName!)
        
        if let addtionalPredicate = predicate {
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [categoryPredicate, addtionalPredicate])
        } else {
            request.predicate = categoryPredicate
        }
        do {
            sheetArray = try context.fetch(request)
        } catch {
            print("Error fetching data from context \(error)")
        }
    }
}
