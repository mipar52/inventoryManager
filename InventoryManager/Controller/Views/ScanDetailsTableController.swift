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
        //tableView.separatorColor = UIColor.clear
        
        print("Uden u mini table view: rezultati: \(results)")
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
    }

    // MARK: - Table view data source
//    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        return 55.0
//    }
    

    
//    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
////        let modelCell = tableView.dequeueReusableCell(withIdentifier: "modelCell")
////        modelCell?.layer.borderColor = #colorLiteral(red: 0.2588235438, green: 0.7568627596, blue: 0.9686274529, alpha: 1)
//        if indexPath.row == 0 && indexPath.section == 0 {
//            cell.separatorInset.left = cell.bounds.size.width
//
//        }
//
//        let lineView = UIView(frame: CGRect(x: 0, y: 0, width: cell.contentView.bounds.size.width, height: 1))
//            lineView.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
////        if let unwrappedVar = UIView.AutoresizingMask(rawValue: 0x3f) {
////            lineView.autoresizingMask = unwrappedVar
////        }
//            cell.contentView.addSubview(lineView)
//        if indexPath.row == tableView.numberOfRows(inSection: indexPath.section) {
//            cell.separatorInset.left = cell.bounds.size.width
//        }
//        let contentView = cell.contentView
//        // this separator is subview of first UITableViewCell in section
//        if indexPath.row == 0,
//            // truing to find it in subviews
//            let divider = cell.subviews.filter({ $0.frame.minY == 0 && $0 !== contentView }).first
//        {
//            divider.isHidden = true
//        }
//        if indexPath.section == 0 {
//            return modelCell
//        }
   // }
    
//    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//
//        let view = UIView(frame: .zero)
//    
//        
//        //view.backgroundColor = #colorLiteral(red: 0.3333333433, green: 0.3333333433, blue: 0.3333333433, alpha: 1)
//        //view.layer.borderColor = #colorLiteral(red: 0.6666666865, green: 0.6666666865, blue: 0.6666666865, alpha: 1)
//
//        //return view
//        return view
//    }
    //override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
             //Background color
//            view.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
//            view.layer.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
//            view.tintColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
//            view.layer.borderColor = #colorLiteral(red: 0.6666666865, green: 0.6666666865, blue: 0.6666666865, alpha: 1)
    
             //Text Color
//            let header = view as? UITableViewHeaderFooterView
//            header?.backgroundColor = #colorLiteral(red: 0.6666666865, green: 0.6666666865, blue: 0.6666666865, alpha: 1)
//            //header?.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
//            header?.textLabel?.textColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
//            header?.backgroundView?.layer.borderColor = #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1)
////
//             Another way to set the background color
//             Note: does not preserve gradient effect of original header
//             header.contentView.backgroundColor = [UIColor blackColor];
            //return header
        //}
//    override func numberOfSections(in tableView: UITableView) -> Int {
//        // #warning Incomplete implementation, return the number of sections
//        return 0
//    }
//
//    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        // #warning Incomplete implementation, return the number of rows
//        return 0
//    }

  
    
//    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//
//        let cell = tableView.dequeueReusableCell(withIdentifier: "modelCell", for: indexPath)
//        let bottomBorder = CALayer()
//
//        bottomBorder.frame = CGRect(x: 0.0, y: 43.0, width: cell.contentView.frame.size.width, height: 1.0)
//        bottomBorder.backgroundColor = UIColor(white: 0.8, alpha: 1.0).cgColor
//        cell.contentView.layer.addSublayer(bottomBorder)
//
//        return cell
//
//    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
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
