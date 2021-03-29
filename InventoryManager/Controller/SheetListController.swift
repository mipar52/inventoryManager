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
            loadSheets()
        }
    }
    
    static var selectedDelegate : selectedSpreadsheet?

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView()
        loadSheets()
    }
    
    @IBAction func updateSheetsPressed(_ sender: UIBarButtonItem) {
        
        let sheetController = UIAlertController(title: "Add Sheet", message: "Add Sheet?", preferredStyle: .alert)
        
        let createNewSheet = UIAlertAction(title: "Create new Sheet", style: .default) { (action) in
            var nameField = UITextField()
            
            let newSheetController = UIAlertController(title: "Create new Sheet", message: "New Sheet", preferredStyle: .alert)
            let create = UIAlertAction(title: "Create", style: .default) { (action) in
                self.utils.ncSpin(message: "Creating Sheet..", vc: self.navigationController!)
                self.sheetBrain.createNewSheet(spreadsheet: self.selectedSpreadsheet!, spreadID: (self.selectedSpreadsheet?.spreadsheetId!)!, sheetName: nameField.text!) { (bool) in
                    self.dismiss(animated: true) {
                        if bool == true {
                     
                            self.utils.showAlert(title: "Sucess", message: "New Sheet added!", vc: self)
                            self.loadSheets()
                        } else {
                            self.utils.showAlert(title: "Error", message: "Could not create sheet! \n1. See if you are connected to the Internet \n2. Check if you are properly signed into your Google Account. \n3. See if you have the right perrmission to edit the Spreadsheet.", vc: self)
                            self.loadSheets()
                        }
                    }
                }
            }
            let cancel = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
                self.dismiss(animated: true, completion: nil)
            }
            newSheetController.addTextField { (field) in
                nameField = field
                nameField.placeholder = "Sheet name"
            }
            newSheetController.addAction(create)
            newSheetController.addAction(cancel)
            self.present(newSheetController, animated: true, completion: nil)
                        
        }
        
        let updateExistingSheets = UIAlertAction(title: "Update existing Sheets", style: .default) { (action) in
            
            let updateController = UIAlertController(title: "Update Existing Sheets", message: "Update Sheets?", preferredStyle: .alert)
            
            let update = UIAlertAction(title: "Update", style: .default) { (action) in
                self.utils.ncSpin(message: " Finding Sheets..", vc: self.navigationController!)

                self.sheetBrain.updateSheets(spreadsheet: self.selectedSpreadsheet!, spreadID: (self.selectedSpreadsheet?.spreadsheetId)!, updateArray: self.sheetArray) { (bool) in
                    self.dismiss(animated: true) {
                        print(self.sheetBrain.newSheetCounter)
                        let counter = self.sheetBrain.newSheetCounter
                        if bool == true {
                            if counter == 0 {
                                self.utils.showAlert(title: "Everything already here", message: "All Sheets already here!", vc: self)
                                self.loadSheets()
                            } else if counter == 1 {
                                self.utils.showAlert(title: "Success", message: "Added 1 Sheet!", vc: self)
                                self.tableView.reloadData()
                                self.loadSheets()
                            } else if counter > 1 {
                            self.utils.showAlert(title: "Success", message: "Added \(self.sheetBrain.newSheetCounter) Sheets!", vc: self)
                            self.tableView.reloadData()
                            self.loadSheets()
                           }
                        } else if bool == false {
                        self.utils.showAlert(title: "Error", message: "Could not update Sheets!", vc: self)
                        self.loadSheets()
                        }
                    }
                }
            }
            let cancel = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
                self.dismiss(animated: true, completion: nil)
            }
            updateController.addAction(update)
            updateController.addAction(cancel)
            self.present(updateController, animated: true, completion: nil)
            
        }
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
            self.dismiss(animated: true, completion: nil)
        }
        sheetController.addAction(createNewSheet)
        sheetController.addAction(updateExistingSheets)
        sheetController.addAction(cancel)
        
        present(sheetController, animated: true, completion: nil)
    }
    
    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sheetArray.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let sheetCell = tableView.dequeueReusableCell(withIdentifier: "sheetCell", for: indexPath)
        
        let sheet = sheetArray[indexPath.row]
        
        sheetCell.textLabel?.text = sheet.sheetName
        sheetCell.selectionStyle = .none
        if sheet.sheetSelected == true {
            sheetCell.accessoryType = .checkmark
            sheetCell.textLabel?.textColor = #colorLiteral(red: 0.5843137503, green: 0.8235294223, blue: 0.4196078479, alpha: 1)
            sheetCell.tintColor = #colorLiteral(red: 0.5843137503, green: 0.8235294223, blue: 0.4196078479, alpha: 1)
        } else {
            sheetCell.accessoryType = .none
            sheetCell.textLabel?.textColor = .white
        }
        return sheetCell
                
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {

        if editingStyle == .delete {
            let alert = UIAlertController(title: "Delete Sheet?", message: "", preferredStyle: .alert)
            let sure = UIAlertAction(title: "YES", style: .default) { (action) in
                
                self.database.context.delete(self.sheetArray[indexPath.row])
                self.sheetArray.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .fade)
                
                self.utils.addToastToNC(messageColor: .black, backgroundColor: #colorLiteral(red: 0.9330014586, green: 0.3689673841, blue: 0.4903494716, alpha: 1), message: "Deleting Sheet..", nc: self.navigationController!)
                self.database.savePassedData()
                    tableView.reloadData()
            }
            let nah = UIAlertAction(title: "NO", style: .cancel) { (action) in
                self.dismiss(animated: true, completion: nil)
            }
            alert.addAction(sure)
            alert.addAction(nah)
            present(alert, animated: true, completion: nil)
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 55.0
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToSheetDetails", sender: self)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToSheetDetails" {
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

extension SheetListController {
    
    func loadSheets(with request: NSFetchRequest<Sheet> = Sheet.fetchRequest(), predicate: NSPredicate? = nil) {
        
        let spreadsheetPredicate = NSPredicate(format: "parentCategory.spreadsheetName LIKE %@", selectedSpreadsheet!.spreadsheetName! as String)
        
        let sort = NSSortDescriptor(key: "sheetName", ascending: true)
            request.sortDescriptors = [sort]
        
        if let addtionalPredicate = predicate {
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [spreadsheetPredicate, addtionalPredicate])
        } else {
            request.predicate = spreadsheetPredicate
        }
        
        do {
            sheetArray = try database.context.fetch(request)
        } catch {
            print("Error fetching data from context \(error)")
        }
        tableView.reloadData()
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
}
