//
//  ScanDetailsTableController.swift
//  InventoryManager
//
//  Created by Milan Parađina on 25.03.2021..
//
import UIKit

class ScanDetailsTableController: UITableViewController {

    @IBOutlet weak var modelText: UILabel!
    @IBOutlet weak var serialNumberText: UILabel!
    @IBOutlet weak var invetoryIdText: UILabel!
    @IBOutlet weak var dateOfPurchaseText: UILabel!
    
    var results : [String]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        handleInfo()
        tableView.tableFooterView = UIView()
    }
    
    func handleInfo () {
        let noinfo = "Not defined"        
        modelText.text = results?[optional: 0] ?? noinfo
        serialNumberText.text = results?[optional: 1] ?? noinfo
        invetoryIdText.text = results?[optional: 2] ?? noinfo
        let dateResult = results![optional: 3]?.replacingOccurrences(of: ";", with: "") ?? noinfo
        dateOfPurchaseText.text = dateResult
    }
}

extension Collection {
    subscript(optional i: Index) -> Iterator.Element? {
        return self.indices.contains(i) ? self[i] : nil
    }
}
