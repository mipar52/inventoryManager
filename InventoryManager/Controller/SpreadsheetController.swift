//
//  SheetController.swift
//  InventoryManager
//
//  Created by Milan Parađina on 25.03.2021..
//

import UIKit
import CoreData


class SpreadsheetController: UITableViewController {
    
    let defaults = UserDefaults.standard
    let sheetBrain = SheetBrain()
    let driveBrain = DriveBrain()
    let database = DataBaseBrain()
    let utils = Utils()
    var spreadsheets = [Spreadsheet]()
    var sheets = [Sheet]()
    var sheetSelected : Bool?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView()
        searchBarPressed.delegate = self
        self.loadSpreadsheets()
        self.refreshControl?.addTarget(self, action: #selector(refresh), for: UIControl.Event.valueChanged)
    }

    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
     return spreadsheets.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let spreadsheetCell = tableView.dequeueReusableCell(withIdentifier: K.identifiers.spreadsheetCell, for: indexPath)
        let spreadsheet = spreadsheets[indexPath.row]
        spreadsheetCell.textLabel?.text = spreadsheet.spreadsheetName
        spreadsheetCell.detailTextLabel?.text = listSheets(spreadsheetName: spreadsheet.spreadsheetName!)
        
        if spreadsheet.spreadsheetSelected == true {
            spreadsheetCell.accessoryType = .checkmark
            spreadsheetCell.textLabel?.textColor = K.colors.success
            spreadsheetCell.detailTextLabel?.textColor = K.colors.success
            spreadsheetCell.tintColor = K.colors.success
        } else {
            spreadsheetCell.accessoryType = .disclosureIndicator
            spreadsheetCell.textLabel?.textColor = .white
            spreadsheetCell.detailTextLabel?.textColor = .white
        }
        return spreadsheetCell
    }
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            self.utils.addTwoActionAlert(title: K.popupStrings.alert.deleteSpreadsheet, message: K.popupStrings.alert.deleteSpreadsheetAction, actionTitle: K.popupStrings.alert.yes, vc: self) { action in
                self.database.context.delete(self.spreadsheets[indexPath.row])
                self.spreadsheets.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .fade)
                self.utils.addToast(backgroundColor: K.colors.error, message: K.popupStrings.spinner.deletingSpreadsheet, vc: self.navigationController!)
                self.database.savePassedData()
                tableView.reloadData()
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: K.segues.sheetList, sender: self)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! SheetListController
        SheetListController.selectedDelegate = self
        if let indexPath = tableView.indexPathForSelectedRow {
            destinationVC.selectedSpreadsheet = spreadsheets[indexPath.row]
        }
    }
    
   @objc func refresh(sender:AnyObject){
       self.driveBrain.findDriveSheets { success, counter in
           if success == true {
               if counter == 0 {
                   self.utils.addToast(backgroundColor: K.colors.neutral, message: K.popupStrings.alert.spreadAlreadyAdded, vc: self)
                   self.loadSpreadsheets()
               } else if counter == 1 {
                   self.utils.addToast(backgroundColor: K.colors.success, message: K.popupStrings.alert.addedOneSheet, vc: self)
                   self.loadSpreadsheets()
               } else if counter! > 1 {
                   self.utils.addToast(backgroundColor: K.colors.success, message: "Added \(counter!) Spreadsheets", vc: self)
                   self.loadSpreadsheets()
              }
           } else if success == false {
               self.utils.addToast(backgroundColor: K.colors.error, message: K.popupStrings.alert.errorUpdateSheet, vc: self)
               self.loadSpreadsheets()
           }
           self.refreshControl?.endRefreshing()
       }
   }
    //MARK: - Search & Add new/exsiting Sheet
    @IBAction func addSheetPressed(_ sender: UIBarButtonItem) {
        let mainAlert = UIAlertController(title: K.popupStrings.alert.newSpreadsheet, message: "", preferredStyle: .alert)
        let createNewSheet = UIAlertAction(title: K.popupStrings.alert.createNewSpreadsheet, style: .default) {
            (action) in
            var createTextField = UITextField()
            createTextField.placeholder = K.popupStrings.alert.spreadsheetName
            self.utils.addTextFieldAlert(title: K.popupStrings.alert.createNewSpreadsheet, message: "", actionTitle: K.popupStrings.alert.create, textField: createTextField, textFieldHolder: "" , vc: self) { action in
                self.utils.showSpinner(message: K.popupStrings.spinner.creatingSheet, vc: self.navigationController!)
                self.sheetBrain.createNewSpreadsheet(sheetName: createTextField.text!) { (bool) in
                    self.dismiss(animated: true) {
                        if bool == true {
                            self.utils.showAlert(title: K.popupStrings.alert.success, message: K.popupStrings.alert.successCreate, vc: self)
                            self.loadSpreadsheets()
                        } else if bool == false{
                            self.utils.showAlert(title: K.popupStrings.alert.error, message: K.popupStrings.alert.errorCreateSpreadSheet, vc: self)
                            self.database.savePassedData()
                        }
                    }
                }
            } fieldAction: { field in
                createTextField = field
            }
        }
        let addExistingSheet = UIAlertAction(title: K.popupStrings.alert.existingSpreadsheet, style: .default) { (action) in
            var urlTextField = UITextField()
            urlTextField.placeholder = K.popupStrings.alert.enterURL
            self.utils.addTextFieldAlert(title: K.popupStrings.alert.existingSpreadsheet, message: "", actionTitle: K.popupStrings.alert.add, textField: urlTextField, textFieldHolder: "", vc: self, action: { action in
                let parsedString = urlTextField.text?.components(separatedBy: "/")
                self.utils.isUrlValid(spreadsheetURL: urlTextField.text!) { isURLValid in
                   if isURLValid == true {
                            print("Url valid!")
                        self.database.fetchExistingSpreadsheet(spreadsheetId: (parsedString?[5])!) { isDuplicated in
                            if isDuplicated == true {
                                self.utils.showAlert(title: K.popupStrings.alert.duplicateSpreadsheet, message: K.popupStrings.alert.duplicateSpreadsheetError, vc: self)
                            } else {
                                self.utils.showSpinner(message: K.popupStrings.spinner.findingSheets, vc: self.navigationController!)
                                self.sheetBrain.findSpreadsheetAndSheets(id: (parsedString?[5])!) { (bool) in
                                self.dismiss(animated: true) {
                                    if bool == true {
                                       self.utils.showAlert(title: K.popupStrings.alert.success, message: K.popupStrings.alert.addedSpread, vc: self)
                                        self.loadSpreadsheets()
                                    } else {
                                       self.utils.showAlert(title: K.popupStrings.alert.error, message: K.popupStrings.alert.errorFindSpread, vc: self)
                                       self.loadSpreadsheets()
                                        }
                                    }
                                }
                            }
                        }
                  } else {
                     self.utils.showAlert(title: K.popupStrings.alert.error, message: K.popupStrings.alert.urlError, vc: self)
                     self.tableView.reloadData()
                  }
                }
                self.tableView.reloadData()
            }, fieldAction: { field in
                urlTextField = field
            })
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
            self.dismiss(animated: true, completion: nil)
        }
        mainAlert.addAction(createNewSheet)
        mainAlert.addAction(addExistingSheet)
        mainAlert.addAction(cancel)
        present(mainAlert, animated: true, completion: nil)
    }
    @IBOutlet weak var searchBarPressed: UISearchBar!
}

extension SpreadsheetController: selectedSpreadsheet, sheetDeleteDelegate {
    func selectSpreadsheet(selected: Bool?) {
        defaults.setValue(true, forKey: K.uDefaults.sheetSelected)
        sheetSelected = (defaults.object(forKey: K.uDefaults.sheetSelected) as! Bool)
        if selected == nil {
            return
        } else {
        if let indexPath = tableView.indexPathForSelectedRow {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Spreadsheet")
            do {
                let results = try database.context.fetch(fetchRequest)
                let selectedSheets = results as! [Spreadsheet]
                for spreadsheet in selectedSheets {
                   spreadsheet.spreadsheetSelected = false
                        }
                       } catch let error as NSError {
                          print("Could not fetch \(error)")
                    }
                    spreadsheets[indexPath.row].spreadsheetSelected = selected!
                    self.database.savePassedData()
                    tableView.reloadData()
                    }
                    tableView.reloadData()
                    }
    }
    
    func deleteSheet(sheet: [Sheet]) {
        if let indexPath = tableView.indexPathForSelectedRow{
            self.database.context.delete(sheet[indexPath.row])
            spreadsheets.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
            tableView.reloadData()
            self.database.savePassedData()
        }
    }
    
    func loadSpreadsheets() {
      let request : NSFetchRequest<Spreadsheet> = Spreadsheet.fetchRequest()
      let sort = NSSortDescriptor(key: "spreadsheetName", ascending: true)
          request.sortDescriptors = [sort]
        do{
            spreadsheets = try self.database.context.fetch(request)
        } catch {
            print("Error loading categories \(error)")
        }
        tableView.reloadData()
    }
    func listSheets(spreadsheetName: String, with request: NSFetchRequest<Sheet> = Sheet.fetchRequest(), predicate: NSPredicate? = nil) -> String {
            var sheetArray : [String] = []
            let spreadsheetPredicate = NSPredicate(format: "parentCategory.spreadsheetName LIKE %@", (spreadsheetName))
            let sort = NSSortDescriptor(key: "sheetName", ascending: true)
                request.sortDescriptors = [sort]
            if let addtionalPredicate = predicate {
                request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [spreadsheetPredicate, addtionalPredicate])
            } else {
                request.predicate = spreadsheetPredicate
            }
            do {
                sheets = try self.database.context.fetch(request)
            } catch {
                print("Error fetching data from context \(error)")
            }
           for sheet in sheets {
            sheetArray.append(sheet.sheetName!)
            }
           let sheetsToDisplay = sheetArray.joined(separator: ", ")
           return sheetsToDisplay
    }
}

extension SpreadsheetController: UISearchBarDelegate, UISearchDisplayDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        //"title CONTAINS[cd] %@",
        //"name contains[c] '\(searchText)'"
        if !searchText.isEmpty {
              var predicate: NSPredicate = NSPredicate()
            predicate = NSPredicate(format:"spreadsheetName CONTAINS[cd] %@", searchBar.text!)
              let fetchRequest = NSFetchRequest<Spreadsheet>(entityName:"Spreadsheet")
              fetchRequest.predicate = predicate
              do {
                spreadsheets = try database.context.fetch(fetchRequest)
              } catch let error as NSError {
                  print("Could not fetch. \(error)")
              }
            tableView.reloadData()
        } else {
            loadSpreadsheets()
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }
    }
}
