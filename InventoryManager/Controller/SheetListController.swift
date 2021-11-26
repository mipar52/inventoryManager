//
//  SheetListController.swift
//  InventoryManager
//
//  Created by Milan Parađina on 25.03.2021..
//

import UIKit
import CoreData

protocol selectedSpreadsheet {
    func selectSpreadsheet(selected: Bool?)
}

class SheetListController: UITableViewController {
    
    let sheetBrain = SheetBrain()
    let database = DataBaseBrain()
    let utils = Utils()
    var sheetArray = [Sheet]()
    var sheetToDelete : [Sheet]?
    var isSheetSelected : Bool?
    var selectedSpreadsheet : Spreadsheet? {
        didSet {
            self.loadSheets()
            
        }
    }
    
    static var selectedDelegate : selectedSpreadsheet?

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView()
        self.loadSheets()
        self.refreshControl?.addTarget(self, action: #selector(refresh), for: UIControl.Event.valueChanged)
    }
    
    @IBAction func updateSheetsPressed(_ sender: UIBarButtonItem) {
        let sheetController = UIAlertController(title: K.popupStrings.alert.addSheet, message: "", preferredStyle: .alert)
        let createNewSheet = UIAlertAction(title: K.popupStrings.alert.createSheet, style: .default) { (action) in
            var nameField = UITextField()
            let newSheetController = UIAlertController(title: K.popupStrings.alert.createSheet , message: "", preferredStyle: .alert)
            let create = UIAlertAction(title: K.popupStrings.alert.create, style: .default) { (action) in
                self.utils.showSpinner(message: K.popupStrings.spinner.creatingSheet, vc: self.navigationController!)
                self.sheetBrain.createNewSheet(spreadsheet: self.selectedSpreadsheet!, spreadID: (self.selectedSpreadsheet?.spreadsheetId!)!, sheetName: nameField.text!) { (bool) in
                    self.dismiss(animated: true) {
                        if bool == true {
                            self.utils.showAlert(title: K.popupStrings.alert.success, message: K.popupStrings.alert.newSheetAdded, vc: self)
                            self.loadSheets()
                        } else {
                            self.utils.showAlert(title: K.popupStrings.alert.error, message: K.popupStrings.alert.errorCreateSheet, vc: self)
                            self.loadSheets()
                        }
                    }
                }
            }
            let cancel = UIAlertAction(title: K.popupStrings.alert.cancel, style: .cancel) { (action) in
                self.dismiss(animated: true, completion: nil)
            }
            newSheetController.addTextField { (field) in
                nameField = field
                nameField.placeholder = K.popupStrings.alert.sheetName
            }
            newSheetController.addAction(create)
            newSheetController.addAction(cancel)
            self.present(newSheetController, animated: true, completion: nil)
        }
        let updateExistingSheets = UIAlertAction(title: K.popupStrings.alert.updateSheets, style: .default) { (action) in
            self.utils.showSpinner(message: K.popupStrings.spinner.findingSheets, vc: self.navigationController!)
                self.sheetBrain.updateSheets(spreadsheet: self.selectedSpreadsheet!, spreadID: (self.selectedSpreadsheet?.spreadsheetId)!) { (success, sheetCounter) in
                    self.dismiss(animated: true) {
                        if success == true {
                            if sheetCounter == 0 {
                                self.utils.showAlert(title: "", message: K.popupStrings.alert.allSheetsHere, vc: self)
                                self.loadSheets()
                            } else if sheetCounter == 1 {
                                self.utils.showAlert(title: K.popupStrings.alert.success, message: K.popupStrings.alert.addedOneSheet, vc: self)
                                self.tableView.reloadData()
                                self.loadSheets()
                            } else if sheetCounter! > 1 {
                                self.utils.showAlert(title: K.popupStrings.alert.success, message: "Added \(sheetCounter) Sheets!", vc: self)
                            self.tableView.reloadData()
                                self.loadSheets()
                           }
                        } else if success == false {
                            self.utils.showAlert(title: K.popupStrings.alert.error, message: K.popupStrings.alert.errorUpdateSheet, vc: self)
                            self.loadSheets()
                        }
                    }
                }
        }
        let cancel = UIAlertAction(title: K.popupStrings.alert.cancel, style: .cancel) { (action) in
            self.dismiss(animated: true, completion: nil)
        }
        sheetController.addAction(createNewSheet)
        sheetController.addAction(updateExistingSheets)
        sheetController.addAction(cancel)
        present(sheetController, animated: true, completion: nil)
    }
    @objc func refresh(sender:AnyObject){
        self.sheetBrain.updateSheets(spreadsheet: self.selectedSpreadsheet!, spreadID: (self.selectedSpreadsheet?.spreadsheetId)!) { (success, sheetCounter) in
            self.dismiss(animated: true) {
                if success == true {
                    if sheetCounter == 0 {
                        self.utils.addToast(backgroundColor: K.colors.neutral, message: K.popupStrings.alert.allSheetsHere, vc: self)
                        self.loadSheets()
                    } else if sheetCounter == 1 {
                        self.utils.addToast(backgroundColor: K.colors.success, message: K.popupStrings.alert.addedOneSheet, vc: self)
                        self.loadSheets()
                        
                    } else if sheetCounter! > 1 {
                        self.utils.addToast(backgroundColor: K.colors.success, message: "Added \(sheetCounter!) Sheets!", vc: self)
                        self.loadSheets()
                    self.tableView.reloadData()
                        self.loadSheets()
                   }
                } else if success == false {
                    self.utils.addToast(backgroundColor: K.colors.error, message: K.popupStrings.alert.errorUpdateSheet, vc: self)
                    self.loadSheets()
                }
                self.refreshControl?.endRefreshing()
            }
        }
    }
    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sheetArray.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let sheetCell = tableView.dequeueReusableCell(withIdentifier: K.identifiers.sheetCell, for: indexPath)
        let sheet = sheetArray[indexPath.row]
        sheetCell.textLabel?.text = sheet.sheetName
        if sheet.sheetSelected == true {
            sheetCell.accessoryType = .checkmark
            sheetCell.textLabel?.textColor = K.colors.success
            sheetCell.tintColor = K.colors.success
        } else {
            sheetCell.accessoryType = .disclosureIndicator
            sheetCell.textLabel?.textColor = .white
        }
        return sheetCell
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50.0
    }
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {

        if editingStyle == .delete {
            self.utils.addTwoActionAlert(title: K.popupStrings.alert.deleteSheet , message: K.popupStrings.alert.deleteSheetAction, actionTitle: K.popupStrings.alert.yes, vc: self) { action in
                self.database.context.delete(self.sheetArray[indexPath.row])
                self.sheetArray.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .fade)
                self.utils.addToast(backgroundColor: K.colors.error, message: K.popupStrings.spinner.deletingSheet, vc: self.navigationController!)
                self.database.savePassedData()
                    tableView.reloadData()
            }
        }
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: K.segues.goTosheetDetails, sender: self)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier ==  K.segues.goTosheetDetails {
            let destVC = segue.destination as! SheetDetailsController
            destVC.selectedSheet = selectedSpreadsheet
            SheetDetailsController.sheetDeleteDelegate = self
            SheetDetailsController.selectedDelegate = self
            if let indexPath = tableView.indexPathForSelectedRow {
                destVC.currentSheetName = sheetArray[indexPath.row].sheetName
            }
        }
    }
}

extension SheetListController: selectedSheetDelegeate, sheetDeleteDelegate {
    
    func deleteSheet(sheet: [Sheet]) {
        
        sheetToDelete = sheet
       
        if let indexPath = tableView.indexPathForSelectedRow{
          
            self.database.context.delete(sheet[indexPath.row])
            sheetArray.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
            
            self.database.savePassedData()
            tableView.reloadData()
            
        }
    }
     func selectedSheet(selected: Bool?) {
         isSheetSelected = selected

         if selected == nil {
             return

         } else {
        
         if let indexPath = tableView.indexPathForSelectedRow {
         let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Sheet")
                        
             do {
                 let results = try database.context.fetch(fetchRequest)
                 let selectedSheets = results as! [Sheet]
                        
                 for spreadsheet in selectedSheets {
                    spreadsheet.sheetSelected = false
                         }
                        } catch let error as NSError {
                           print("Could not fetch \(error)")
                     }
                     sheetArray[indexPath.row].sheetSelected = isSheetSelected!
            for sheet in sheetArray {
                if sheet.sheetSelected == true {
                    SheetListController.self.selectedDelegate?.selectSpreadsheet(selected: true)
                }
            }
                     self.database.savePassedData()
                     tableView.reloadData()
                     
                     }
                         tableView.reloadData()
                     }
                     }
    func loadSheets(with request: NSFetchRequest<Sheet> = Sheet.fetchRequest(), predicate: NSPredicate? = nil) {
        
        let spreadsheetPredicate = NSPredicate(format: "parentCategory.spreadsheetName LIKE %@", (selectedSpreadsheet?.spreadsheetName)!)
        let sort = NSSortDescriptor(key: "sheetName", ascending: true)
            request.sortDescriptors = [sort]
        if let addtionalPredicate = predicate {
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [spreadsheetPredicate, addtionalPredicate])
        } else {
            request.predicate = spreadsheetPredicate
        }
        do {
            sheetArray = try self.database.context.fetch(request)
        } catch {
            print("Error fetching data from context \(error)")
        }
        tableView.reloadData()
    }
}
