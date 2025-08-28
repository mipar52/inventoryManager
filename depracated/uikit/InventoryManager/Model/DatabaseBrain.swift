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

    let sheetBrain = SheetBrain()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var spreadsheetArray = [Spreadsheet]()
    var dataArray = [ScannedData]()
    var sheetArray = [Sheet]()
    
    func savePassedData() {
        do {
        try context.save()
        print("Data saved!")
        } catch {
        print("Error saving category \(error)")
        }
    }
    
    func deleteAllData(entity: String, completionHandler: @escaping (Bool) -> Void) {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: entity)
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        do {
            try context.execute(deleteRequest)
            completionHandler(true)
        } catch let error as NSError {
            print("Error with deleting all entities: \(error)")
            completionHandler(false)
        }
    }

  func fetchExistingSpreadsheet (spreadsheetId: String, completionHandler: @escaping (Bool) -> Void) {
          let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Spreadsheet")
          fetchRequest.fetchLimit =  1
          fetchRequest.predicate = NSPredicate(format: "spreadsheetId == [d] %@" ,spreadsheetId)
          fetchRequest.includesPendingChanges = false
          do {
              let count = try context.count(for: fetchRequest)
              if count > 0 {
                  completionHandler(true)
              } else {
                  completionHandler(false)
              }
          } catch let error as NSError {
              print("Could not fetch. \(error), \(error.userInfo)")
          }
  }
    func fetchExistingSheets (sheetName: String?, sheetId: String?, spreadSheet: Spreadsheet, completionHandler: @escaping (Bool, Int) -> Void) {
        let request: NSFetchRequest<Sheet> = Sheet.fetchRequest()
        request.fetchLimit =  1
        let spreadsheetPredicate = NSPredicate(format: "parentCategory == %@", spreadSheet)
        let sheetPredicate = NSPredicate(format: "sheetName == %@" ,sheetName!)
        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [spreadsheetPredicate, sheetPredicate])
        request.includesPendingChanges = false
        request.includesSubentities = false
        var newSheetCount = 0
        do {
            let count = try context.count(for: request)
            if count > 0 {
                print("count is \(count)")
                completionHandler(true, newSheetCount)
            } else if count == 0 {
                newSheetCount += 1
                let newSheet = Sheet(context: context)
                newSheet.sheetName = sheetName
                newSheet.sheetId = sheetId
                newSheet.parentCategory = spreadSheet
                sheetArray.append(newSheet)
                savePassedData()
                completionHandler(false, newSheetCount)
            }
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
//    func loadSpreadSheets(with request: NSFetchRequest<Spreadsheet> = Spreadsheet.fetchRequest(), predicate: NSPredicate? = nil) {
//        let categoryPredicate = NSPredicate(format: "parentCategory.spreadsheetName MATCHES %@", selectedSpreadsheet!.spreadsheetName!)
//        if let addtionalPredicate = predicate {
//            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [categoryPredicate, addtionalPredicate])
//        } else {
//            request.predicate = categoryPredicate
//        }
//        do {
//            spreadsheetArray = try context.fetch(request)
//        } catch {
//            print("Error fetching data from context \(error)")
//        }
//    }
}
