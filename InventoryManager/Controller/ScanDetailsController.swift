//
//  ScanDetailsController.swift
//  InventoryManager
//
//  Created by Milan Parađina on 25.03.2021..
//

import UIKit
import CoreData

protocol DataDeleteDelegate {

    func deleteScannedData (data: [ScannedData], uploaded: Bool)
}

class ScanDetailsController: UIViewController {

    @IBOutlet weak var modelText: UILabel!
    @IBOutlet weak var serialNumber: UILabel!
    @IBOutlet weak var inventoryId: UILabel!
    @IBOutlet weak var dataOfPurchase: UILabel!
    @IBOutlet weak var additionalInfo: UILabel!
    
    let sheetBrain = SheetBrain()
    let database = DataBaseBrain()
    let utils = Utils()
    var dataArray = [ScannedData]()

    static var deleteDelegate : DataDeleteDelegate?

    var seletectedItem: ScannedData? {
        didSet{
            loadPassedData()
        }
    }
    
    var currentSheetforUploadDetails : String?
    var couldNotSend : Bool?
    
    let defaults = UserDefaults.standard

    @IBAction func uploadPressed(_ sender: UIButton) {
 
        utils.showSpinner(message: "Sending data..", vc: self)

        var parsedData = self.seletectedItem?.scannedData?.components(separatedBy: (";" + "\n"))
        
        if parsedData!.count > 1 {
        parsedData![parsedData!.endIndex] = (parsedData?.last?.replacingOccurrences(of: ";", with: ""))!
        }
        
        let dataToUpload : Array<[Any]>.ArrayLiteralElement = parsedData!
        
        self.sheetBrain.sendDataToSheet(results: dataToUpload, failedData: nil) { (bool) in
            print(bool)
            if bool == true {
                self.deleteData()
                self.dismiss(animated: true) {
                    ScanDetailsController.deleteDelegate?.deleteScannedData(data: self.dataArray, uploaded: true)
                    self.navigationController?.popViewController(animated: true)
                }
            } else if bool == false {
                self.utils.showAlert(title: "Error", message: "Could not upload the result!\nTry seeing if you are connected to the interet and properly signed into your Google account!", vc: self)
            }
        }
    }

    @IBAction func deletePressed(_ sender: UIButton) {
        
        utils.addToast(messageColor: .black, backgroundColor: #colorLiteral(red: 0.9363915324, green: 0.4701347947, blue: 0.6925068498, alpha: 1), message: "Deleting item...", vc: self)
        self.deleteData()
        ScanDetailsController.deleteDelegate?.deleteScannedData(data: self.dataArray, uploaded: false)
        self.navigationController?.popViewController(animated: true)

    }
    
    //MARK: - Data Manipulation methods
    func loadPassedData() {

        let request : NSFetchRequest<ScannedData> = ScannedData.fetchRequest()

        do{
            dataArray = try database.context.fetch(request)
        } catch {
            print("Error loading categories \(error)")
        }
    }

    func deleteData(){
        database.context.delete(seletectedItem!)
        database.savePassedData()
    }
}
extension ScanDetailsController {
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "tableViewScanDetails" {
            let tableView = segue.destination as! ScanDetailsTableController
            let parsedData = self.seletectedItem?.scannedData?.components(separatedBy: (";" + "\n"))
            tableView.results = parsedData
        }
    }
}
