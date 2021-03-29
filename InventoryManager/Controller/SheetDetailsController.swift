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
   
        NotificationCenter.default.post(name: .sheetIdNotificationKey, object: self)
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "sheetBrainId"), object: self)
        NotificationCenter.default.post(name: .sheetIdNotificationKey, object: self)
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "sheetBrainId"), object: self)

        self.navigationController!.popToRootViewController(animated: true)
        self.utils.addToastToNC(messageColor: .black, backgroundColor: #colorLiteral(red: 0.5843137503, green: 0.8235294223, blue: 0.4196078479, alpha: 1), message: "Selected Spreadsheet\n\(name)!", nc: self.navigationController!)
        self.navigationController?.navigationItem.backBarButtonItem?.isEnabled = true
        self.navigationController!.interactivePopGestureRecognizer!.isEnabled = true
        SheetDetailsController.self.selectedDelegate?.selectedSheet(selected: isSelected)
    }
    
    
    @IBAction func deleteSheetPressed(_ sender: UIButton) {
        
        let alert = UIAlertController(title: "Delete Spreadsheet?", message: "", preferredStyle: .alert)
        let deleteSheetFromApp = UIAlertAction(title: "Yes", style: .default) { (action) in
            SheetDetailsController.self.sheetDeleteDelegate?.deleteSheet(sheet: self.sheetArray)
            self.navigationController?.popViewController(animated: true)
        }
        
        let cancel = UIAlertAction(title: "No", style: .default) { (action) in
            self.navigationController?.popViewController(animated: true)
          }
        alert.addAction(deleteSheetFromApp)
        alert.addAction(cancel)
        
        present(alert, animated: true, completion: nil)
    }
    
    @IBAction func sheetURLPressed(_ sender: UIBarButtonItem) {
        copySheetUrl()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "sheetDetails" {
            let destVC = segue.destination as! SheetDetailTableController
            destVC.spreadSheetName = selectedSheet?.spreadsheetName
            destVC.sheetId = selectedSheet?.spreadsheetId
            destVC.sheetName = currentSheetName
        }
    }
    
    //MARK: - Sheet Info
    func copySheetUrl() {
            UIPasteboard.general.string = "https://docs.google.com/spreadsheets/d/\(selectedSheet!.spreadsheetId!)/"
        self.utils.addToastToNC(messageColor: .black, backgroundColor: #colorLiteral(red: 0.5843137503, green: 0.8235294223, blue: 0.4196078479, alpha: 1), message: "Spreadsheet URL copied!", nc: self.navigationController!)
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
extension Notification.Name {
    static let sheetIdNotificationKey = Notification.Name("sheetId")
    static let sheetIdForResults = Notification.Name("sheetIdForResults")
    static let sheetIdForDetails = Notification.Name("sheetIdForDetails")
}
