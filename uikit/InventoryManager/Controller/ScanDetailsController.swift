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
    let defaults = UserDefaults.standard
    
    static var deleteDelegate : DataDeleteDelegate?
    var seletectedItem: ScannedData? {
        didSet{
            self.loadScannedData()
        }
    }
    var couldNotSend : Bool?

    @IBAction func uploadPressed(_ sender: UIButton) {
        utils.showSpinner(message: K.popupStrings.spinner.sendingData, vc: self)
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
                self.utils.showAlert(title: K.popupStrings.alert.error, message: K.popupStrings.alert.errorUploadData, vc: self)
            }
        }
    }

    @IBAction func deletePressed(_ sender: UIButton) {
        utils.addToast(backgroundColor: K.colors.error, message: "Deleting item...", vc: self)
        self.deleteData()
        ScanDetailsController.deleteDelegate?.deleteScannedData(data: self.dataArray, uploaded: false)
        self.navigationController?.popViewController(animated: true)
    }
}
extension ScanDetailsController {
    func deleteData(){
        database.context.delete(seletectedItem!)
        database.savePassedData()
    }
    
    func loadScannedData() {
        let request : NSFetchRequest<ScannedData> = ScannedData.fetchRequest()
        do{
            dataArray = try self.database.context.fetch(request)
        } catch {
            print("Error loading categories \(error)")
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == K.segues.tableViewScanDetails {
            let tableView = segue.destination as! ScanDetailsTableController
            let parsedData = self.seletectedItem?.scannedData?.components(separatedBy: (";" + "\n"))
            tableView.results = parsedData
        }
    }
}
