//
//  SheetController.swift
//  InventoryManager
//
//  Created by Milan Parađina on 25.03.2021..
//

import UIKit
import CoreData


class SheetController: UITableViewController {
    
    let defaults = UserDefaults.standard
    let sheetBrain = SheetBrain()
    let database = DataBaseBrain()
    let utils = Utils()
    var spreadsheets = [Spreadsheet]()
    var sheetSucess : Bool?
    var isSheetSelected : Bool?
    var passedSheetId: String?
    var savedSheetId: String?
    var sheet: [NSManagedObject] = []
    var isSheetNil: Bool = false
    var sheetSelected : Bool?
    var disclamer : Bool?
    var sheetToDelete : [Sheet]?
 
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.tableFooterView = UIView()

        searchBarPressed.delegate = self
        
        loadSpreadsheets()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        sheetSelected = (defaults.object(forKey: "sheetSelected") as? Bool ?? false)
        if sheetSelected == false {
            self.navigationItem.hidesBackButton = true
            self.navigationController?.navigationItem.backBarButtonItem?.isEnabled = false
        } else {
            self.navigationItem.hidesBackButton = false
            self.navigationController?.navigationItem.backBarButtonItem?.isEnabled = true
        }
        
        disclamer = (defaults.object(forKey: "disclamer") as? Bool ?? false)
        
        if disclamer == false{
            self.utils.showAlert(title: "Sheet select", message: "Plese pick a Spreadsheet for your first upload!", vc: self)
            disclamer = true
            defaults.setValue(disclamer, forKey: "disclamer")
            
        }
        
        
    }

    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
     return spreadsheets.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let spreadsheetCell = tableView.dequeueReusableCell(withIdentifier: "spreadsheetCell", for: indexPath)
        let spreadsheet = spreadsheets[indexPath.row]
        
        spreadsheetCell.textLabel?.text = spreadsheet.spreadsheetName
        spreadsheetCell.selectionStyle = .none
        
        if spreadsheet.spreadsheetSelected == true {
            spreadsheetCell.accessoryType = .checkmark
            spreadsheetCell.textLabel?.textColor = #colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 1)
            spreadsheetCell.tintColor = #colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 1)
        } else {
            spreadsheetCell.accessoryType = .none
            spreadsheetCell.textLabel?.textColor = .white
        }
        return spreadsheetCell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 55.0
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {

        if editingStyle == .delete {
            let alert = UIAlertController(title: "Delete Spreadsheet?", message: "", preferredStyle: .alert)
            let sure = UIAlertAction(title: "YES", style: .default) { (action) in
                self.database.context.delete(self.spreadsheets[indexPath.row])
                self.spreadsheets.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .fade)
                self.utils.addToastToNC(messageColor: .black, backgroundColor: #colorLiteral(red: 0.9330014586, green: 0.3689673841, blue: 0.4903494716, alpha: 1), message: "Deleting Spreadsheet..", nc: self.navigationController!)
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
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "gpToSheetList", sender: self)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let destinationVC = segue.destination as! SheetListController
        SheetListController.selectedDelegate = self
        if let indexPath = tableView.indexPathForSelectedRow {
            destinationVC.selectedSpreadsheet = spreadsheets[indexPath.row]
        }
    }
    
    //MARK: - Search & Add new/exsiting Sheet
    
    @IBAction func addSheetPressed(_ sender: UIBarButtonItem) {
                
        let mainAlert = UIAlertController(title: "Add New Google Spreadsheet", message: "", preferredStyle: .alert)
        
        let createNewSheet = UIAlertAction(title: "Create New Sheet", style: .default) {
            (action) in
            
            var createTextField = UITextField()
            
            let newSheetAlertController = UIAlertController(title: "Create a new Sheet", message: "", preferredStyle: .alert)
            
            let createSheetAction = UIAlertAction(title: "Create Sheet", style: .default) { (action) in
                
                self.utils.ncSpin(message: "Creating Sheet..", vc: self.navigationController!)
                self.sheetBrain.createNewSpreadsheet(sheetName: createTextField.text!) { (bool) in
                    self.dismiss(animated: true) {
                        if bool == true {
                            self.utils.showAlert(title: "Success", message: "New Spreadsheet created!", vc: self)
                            self.loadSpreadsheets()
                        } else if bool == false{
                            self.utils.showAlert(title: "Error", message: "Could not create sheet!\nPlease check your internet connection and if you are properly signed in your Google account!", vc: self)
                             self.database.savePassedData()
                        }
                    }
                }
            }
            
            let cancelCreate = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
                
                self.dismiss(animated: true, completion: nil)
            }
            newSheetAlertController.addTextField { (field) in
                createTextField = field
                createTextField.placeholder = "Spreadsheet name"
            }
            newSheetAlertController.addAction(createSheetAction)
            newSheetAlertController.addAction(cancelCreate)
            self.present(newSheetAlertController, animated: true, completion: nil)

        }
        
        let addExistingSheet = UIAlertAction(title: "Add existing Sheet", style: .default) { (action) in
            var urlTextField = UITextField()
            let addExistingAlertController = UIAlertController(title: "Add existing Spreadsheet", message: "", preferredStyle: .alert)
            let addExistingAction = UIAlertAction(title: "Add existing sheet", style: .default) { [self] (action) in

                let parsedString = urlTextField.text?.components(separatedBy: "/")
                self.utils.isUrlValid(spreadsheetURL: urlTextField.text!)
          
                if self.utils.isURLValid == true {
                        print("Url valid!")
                        self.database.fetchExistingSpreadsheet(spreadsheetId: (parsedString?[5])!)
                            print("Is sheet duplicated: \(database.isSheetDuplicated)")
                        if self.database.isSheetDuplicated == true {
                            
                            self.utils.showAlert(title: "Duplicated spreadsheet!", message: "Sheet with the same URL already added!", vc: self)
                        self.tableView.reloadData()

                        } else if self.database.isSheetDuplicated == false {
                            self.utils.ncSpin(message: "Finding Sheets..", vc: self.navigationController!)
                            self.sheetBrain.findSpreadNameAndSheets(id: (parsedString?[5])!) { (bool) in
                                self.dismiss(animated: true) {
                                    if bool == true {
                                        self.utils.showAlert(title: "Sucess", message: "Added Spreadsheet to your list!", vc: self)
                                        self.loadSpreadsheets()
                                    } else {
                                        self.utils.showAlert(title: "Error!", message: "Could not find sheet!\nPlease check your internet connection and if you are properly signed in your Google account!", vc: self)
                                        self.loadSpreadsheets()
                                    }
                                }
                            }
                        }
                        } else {
                        self.utils.showAlert(title: "Error", message: "Enter a valid URL!", vc: self)
                        self.tableView.reloadData()
                        }
                self.tableView.reloadData()
                
            }
            let cancelExisting = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
                self.dismiss(animated: true, completion: nil)
            }
            addExistingAlertController.addAction(addExistingAction)
            addExistingAlertController.addAction(cancelExisting)
            addExistingAlertController.addTextField { (field) in
                urlTextField = field
                urlTextField.placeholder = "Enter Spreadsheet URL"
            }
            self.present(addExistingAlertController, animated: true, completion: nil)
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
    
      func loadSpreadsheets() {
          
          let request : NSFetchRequest<Spreadsheet> = Spreadsheet.fetchRequest()
        let sort = NSSortDescriptor(key: "spreadsheetName", ascending: true)
            request.sortDescriptors = [sort]
          
          do{
            spreadsheets = try database.context.fetch(request)
          } catch {
              print("Error loading categories \(error)")
          }
          tableView.reloadData()
      }
}

extension SheetController: selectedSpreadsheet, sheetDeleteDelegate {
    
    
    func selectSpreadsheet(selected: Bool?) {
        isSheetNil = true
        defaults.setValue(isSheetNil, forKey: "sheetSelected")
        sheetSelected = (defaults.object(forKey: "sheetSelected") as! Bool)
  
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
        sheetToDelete = sheet
       
        if let indexPath = tableView.indexPathForSelectedRow{
          
            self.database.context.delete(sheet[indexPath.row])
            spreadsheets.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
            tableView.reloadData()
            self.database.savePassedData()
        }
    }
}
extension SheetController: UISearchBarDelegate, UISearchDisplayDelegate {
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

