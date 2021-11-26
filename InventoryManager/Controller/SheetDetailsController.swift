//
//  SheetDetailsController.swift
//  InventoryManager
//
//  Created by Milan Parađina on 25.03.2021..
//

import UIKit
import CoreData
import Toast_Swift

protocol selectedSheetDelegeate {
    func selectedSheet(selected: Bool?)
}

protocol sheetDeleteDelegate{
    func deleteSheet(sheet: [Sheet])
}

class SheetDetailsController: UIViewController {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var sheetIdLabel: UILabel!
    @IBOutlet weak var sheetUrlLabel: UILabel!
    @IBOutlet weak var sheetBtm: UIButton!
    
    var currentSheetName : String?
    let sheetBrain = SheetBrain()
    let database = DataBaseBrain()
    let utils = Utils()
    var sheetArray = [Sheet]()

    let defaults = UserDefaults.standard
    static var sheetDeleteDelegate : sheetDeleteDelegate?
    static var selectedDelegate : selectedSheetDelegeate?

    var sheetName: String!

    var selectedSheet : Spreadsheet? {
        didSet{
            loadSheets()
        }
    }
    
    @IBAction func useSheetPressed(_ sender: UIButton) {
        
        let isSelected = true
        let name = "\"\(String(describing: selectedSheet!.spreadsheetName!))\"\n(\(currentSheetName!))"
        defaults.set(name, forKey: K.uDefaults.toastSheetName)
        defaults.set(selectedSheet?.spreadsheetId, forKey: K.uDefaults.spreadsheetId)
        defaults.set(currentSheetName, forKey: K.uDefaults.sheetName)
        self.navigationController?.popToRootViewController(animated: true)
        self.utils.addToast(backgroundColor: K.colors.neutral, message: "Selected Spreadsheet\n\(name)!", vc: self.navigationController!)
        SheetDetailsController.self.selectedDelegate?.selectedSheet(selected: isSelected)
    }
    
    
    @IBAction func deleteSheetPressed(_ sender: UIButton) {
        self.utils.addTwoActionAlert(title: K.popupStrings.alert.deleteSpreadsheet, message: "", actionTitle: K.popupStrings.alert.yes, vc: self) { action in
            SheetDetailsController.self.sheetDeleteDelegate?.deleteSheet(sheet: self.sheetArray)
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    @IBAction func sheetURLPressed(_ sender: UIBarButtonItem) {
        copySheetUrl()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == K.segues.sheetDetails {
            let destVC = segue.destination as! SheetDetailTableController
            destVC.spreadSheetName = selectedSheet?.spreadsheetName
            destVC.sheetId = selectedSheet?.spreadsheetId
            destVC.sheetName = currentSheetName
        }
    }
    
    //MARK: - Sheet Info
    func copySheetUrl() {
            UIPasteboard.general.string = "https://docs.google.com/spreadsheets/d/\(selectedSheet!.spreadsheetId!)/"
        self.utils.addToast(backgroundColor: K.colors.neutral, message: K.popupStrings.toast.sheetUrl, vc: self.navigationController!)
    }
    //MARK: - Sheet Data manipulation
    
    func loadSheets(with request: NSFetchRequest<Sheet> = Sheet.fetchRequest(), predicate: NSPredicate? = nil) {
        
        let spreadsheetPredicate = NSPredicate(format: "parentCategory.spreadsheetName MATCHES %@", selectedSheet!.spreadsheetName!)
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
    }
}
