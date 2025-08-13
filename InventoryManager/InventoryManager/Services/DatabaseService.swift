//
//  DatabaseService.swift
//  InventoryManager
//
//  Created by Milan Parađina on 12.08.2025..
//

import CoreData
import Foundation

@MainActor
final class DatabaseService: ObservableObject {
    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "InventoryManager")

        if inMemory {
            let desc = NSPersistentStoreDescription()
            desc.type = NSInMemoryStoreType
            container.persistentStoreDescriptions = [desc]
        }

        container.loadPersistentStores { _, error in
            if let error = error {
                debugPrint("[DatabaseService] load error – \(error.localizedDescription)")
            }
        }

        // Main context config
        let ctx = container.viewContext
        ctx.automaticallyMergesChangesFromParent = true
        ctx.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    }
    
    private func loadContainer() {
        container.loadPersistentStores { description, error in
            if let error = error {
                debugPrint("[DatabaseService] error - \(error.localizedDescription)")
            }
        }
    }
    
    // saving changes
    func saveContextIfNeeded() throws {
        let context = container.viewContext
        guard context.hasChanges else { return }
        try context.save()
    }
    
    func performBackground(_ block: @escaping (NSManagedObjectContext) -> Void) {
        container.performBackgroundTask { ctx in
            ctx.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
            block(ctx)
            if ctx.hasChanges {
                do { try ctx.save() }
                catch { debugPrint("[DatabaseService] bg save error – \(error)") }
            }
        }
    }
    
    func createSpreadsheetsWithSheets(_ spreadsheets: [GoogleSpreadsheet]) async throws {
        return try await withCheckedThrowingContinuation { continuation in
            performBackground { context in
                do {
                    for spreadsheet in spreadsheets {
                        let createdSpreadsheet = try Spreadsheet.getOrCreate(with: spreadsheet.id, name: spreadsheet.name, context)
                        
                        for sheet in spreadsheet.sheets {
                            let _ = try Sheet.getOrCreate(with: sheet.id, name: sheet.name, spreadsheet: createdSpreadsheet, context)
                            }
                    }
                    continuation.resume()
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    // Spreadsheet CRUD
    func createSpreadsheet(spreadsheetId: String, spreadsheetName: String) async throws -> NSManagedObjectID {
        return try await withCheckedThrowingContinuation { continuation in
            performBackground { context in
                do {
                    let spreadsheet = try Spreadsheet.getOrCreate(with: spreadsheetId, name: spreadsheetName, context)
                    continuation.resume(returning: spreadsheet.objectID)
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    func getAllSpreadsheets(sortedBy key: String = "name", ascending: Bool = true) async throws -> [Spreadsheet] {
        try await container.viewContext.perform {
            let request: NSFetchRequest<Spreadsheet> = Spreadsheet.fetchRequest()
            request.sortDescriptors = [NSSortDescriptor(key: key, ascending: ascending)]
            return try self.container.viewContext.fetch(request)
        }
    }
    
    func deleteSpreadsheet(with spreadsheetId: String) {
        performBackground { context in
            do {
                if let spredsheet = try context.fetch(Spreadsheet.fetchSpreadsheet(id: spreadsheetId)).first {
                    context.delete(spredsheet)
                }
            } catch {
                debugPrint("[DBService] - error deleting spreadsheet: \(error.localizedDescription)")
            }
        }
    }
    
    func deleteAllSpreadsheets() throws {
        performBackground { context in
            let request: NSFetchRequest<NSFetchRequestResult> = Spreadsheet.fetchRequest()
            let spreadsheetBatchDelete = NSBatchDeleteRequest(fetchRequest: request)
            spreadsheetBatchDelete.resultType = .resultTypeObjectIDs
            
            do {
                if let result = try context.execute(spreadsheetBatchDelete) as? NSBatchDeleteResult,
                   let objectIds = result.result as? [NSManagedObjectID] {
                    let changes: [AnyHashable: Any] = [NSDeletedObjectsKey: objectIds]
                    
                    NSManagedObjectContext.mergeChanges(
                        fromRemoteContextSave: changes,
                        into: [self.container.viewContext]
                    )
                }
            } catch {
                debugPrint("[DBService] - failed to delete all spreadsheets - \(error.localizedDescription)")
            }
        }
    }

    
    // Sheet CRUD
    func createSheet(sheetId: String, sheetName: String, spreadsheet: NSManagedObjectID) async throws {
        return try await withCheckedThrowingContinuation { continutation in
            performBackground { context in
                do {
                    guard let spreadsheet = try context.existingObject(with: spreadsheet) as? Spreadsheet else {
                        throw GoogleAuthError.ServiceUnavailable
                    }
                    let _ = try Sheet.getOrCreate(with: sheetId, name: sheetName, spreadsheet: spreadsheet, context)
                    
                    continutation.resume()
                } catch {
                    continutation.resume(throwing: error)
                }
            }
        }
    }
    
    func getAllSheetsFromSpreadsheet(from spredsheetId: String) async throws -> [Sheet]{
        try await container.viewContext.perform {
            let request: NSFetchRequest<Sheet> = Sheet.fetchRequest()
            request.predicate = NSPredicate(format: "spreadsheet.spreadsheetId = %@", spredsheetId)
            return try self.container.viewContext.fetch(request)
        }
    }
    
    func deleteSheets(with spreadsheetId: String) {
        performBackground { context in
            let request: NSFetchRequest<NSFetchRequestResult> = Sheet.fetchRequest()
            request.predicate = NSPredicate(format: "spreadsheet.spreadsheetId = %@", spreadsheetId)
            let batch = NSBatchDeleteRequest(fetchRequest: request)
            do {
                try context.execute(batch)
            } catch {
                debugPrint("[DBService] - error deleting sheets: \(error.localizedDescription)")
            }
        }
    }
}

extension Spreadsheet {
    
    static func fetchSpreadsheet(id googleId: String) -> NSFetchRequest<Spreadsheet> {
        let request: NSFetchRequest<Spreadsheet> = Spreadsheet.fetchRequest()
        request.predicate = NSPredicate(format: "spreadsheetId == %@", googleId)
        request.fetchLimit = 1
        return request
    }
    
    static func getOrCreate(with googleId: String, name: String, _ context: NSManagedObjectContext) throws -> Spreadsheet {
        if let existingSpreadsheet = try context.fetch(fetchSpreadsheet(id: googleId)).first { return existingSpreadsheet}
        let newObject = Spreadsheet(context: context)
        newObject.id = UUID()
        newObject.name = name
        newObject.spreadsheetId = googleId
        return newObject
    }
}

extension Sheet {
    
    static func fetchSheet(id sheetId: String, spreadsheetId: String) -> NSFetchRequest<Sheet> {
        let request: NSFetchRequest<Sheet> = Sheet.fetchRequest()
        request.predicate = NSPredicate(format: "sheetId == %@ AND spreadsheet.spreadsheetId == %@", sheetId, spreadsheetId)
        request.fetchLimit = 1
        return request
    }
    
    static func getOrCreate(with sheetId: String, name: String, spreadsheet: Spreadsheet, _ context: NSManagedObjectContext) throws -> Sheet {
        if let exisitingSheet = try context.fetch(fetchSheet(id: sheetId, spreadsheetId: spreadsheet.spreadsheetId!)).first { return exisitingSheet}
        let newObject = Sheet(context: context)
        newObject.id = UUID()
        newObject.name = name
        newObject.sheetId = sheetId
        newObject.spreadsheet = spreadsheet
        return newObject
    }
}
