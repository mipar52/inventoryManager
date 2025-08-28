//
//  SheetDetailTableController.swift
//  InventoryManager
//
//  Created by Milan Parađina on 25.03.2021..
//

import UIKit

class SheetDetailTableController: UITableViewController {

    @IBOutlet weak var sheetNameText: UILabel!
    @IBOutlet weak var sheetIdText: UILabel!
    @IBOutlet weak var sheetUrlText: UILabel!
 
    var spreadSheetName : String?
    var sheetName: String?
    var sheetId : String?
    var sheetUrl : String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView()
        handleSheetInfo()
    }
    
    func handleSheetInfo() {

        let noInfo = "No information added"
        sheetUrlText.adjustsFontSizeToFitWidth = true
        sheetIdText .adjustsFontSizeToFitWidth = true
        sheetUrlText.minimumScaleFactor = 0.85
        sheetUrlText.numberOfLines = 2
        
        sheetNameText.text = "\(spreadSheetName!) (\(sheetName!))" ?? noInfo
        sheetIdText.text = sheetId ?? noInfo
        sheetUrlText.text = "https://docs.google.com/spreadsheets/d/\n\(sheetId!)/" ?? noInfo
        sheetIdText.sizeToFit()
        sheetUrlText.sizeToFit()
    }
}
