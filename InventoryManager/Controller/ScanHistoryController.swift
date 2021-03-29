//
//  ScanHistoryController.swift
//  InventoryManager
//
//  Created by Milan Parađina on 25.03.2021..
//

import UIKit
import CoreData
import Toast_Swift

class ScanHistoryController: UITableViewController, DataDeleteDelegate  {
  
    let sheetBrain = SheetBrain()
    let database = DataBaseBrain()
    let utils = Utils()
    
    var dataArray = [ScannedData]()
    var dataToDelete : [ScannedData]?

    var dataPassed : [String]!
    
    var isUploaded: Bool?
    var currentSheetforUpload : String?

    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.tableFooterView = UIView()
        sheetBrain.showSheetName(VC: self.navigationController)
        
        loadPassedData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
         super.viewWillAppear(animated)
        
        if isUploaded == true {
            self.utils.showAlert(title: "Sucess", message: "Data uploaded!", vc: self)
                  isUploaded = nil
            loadPassedData()
              } else if isUploaded == false{
                self.utils.showAlert(title: "", message: "Data deleted!", vc: self)
                  isUploaded = nil

                loadPassedData()
              }
     }
        
    @IBAction func uploadAllPressed(_ sender: UIBarButtonItem) {
    
        var multiResults: [[String]] = [[]]

        if self.dataArray.count == 0 {
            self.utils.showAlert(title: "No data", message: "No data to send!", vc: self)
        } else {

            if self.dataArray.count == 1 {
                self.utils.showSpinner(message: "Uploading 1 item..", vc: self)
             
            } else if self.dataArray.count > 1 {
                self.utils.showSpinner(message: "Uploading \(self.dataArray.count) items..", vc: self)
                
            }
            
            let group = DispatchGroup()
                multiResults.removeAll()
            for element in self.dataArray {
                group.enter()
                let item = element.scannedData
          
                let parsedItem = item?.components(separatedBy: ";")
                print("Current parsed items : \(String(describing: parsedItem))")
                
                multiResults.append(parsedItem!)
                for result in multiResults {
                    print(result)
                }
                
                group.leave()
                }
            group.wait()
            
            DispatchQueue.main.async {
                let data : Array<Any>.ArrayLiteralElement = multiResults
                self.sheetBrain.sendMulitpleRequests(results: data) { (bool) in
                    
                    print("Podaci:\(data)")
                    if bool == true {
                        for element in self.dataArray {
                            self.database.context.delete(element)
                            print("deleted")
                        }
                        self.dataArray.removeAll()
                        self.database.savePassedData()
                        self.loadPassedData()
                        self.dismiss(animated: true) {
                            self.utils.showAlert(title: "Success", message: "Upload complete!", vc: self)
                        }
                    } else {
                        self.dismiss(animated: true) {
                        self.utils.showAlert(title: "Error", message: "Could not upload items to sheet! \nSee if there is a secure connection to the internet or if you are properly signed into your Google account!", vc: self)
                        }
                    }
                }
            }
        }
    }
    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArray.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        let info = dataArray[indexPath.row].scannedData
        let parsedInfo = info?.components(separatedBy: ";")
        
            cell.textLabel?.text = "\(parsedInfo?[0] ?? "No data")"

        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 55.0
    }
    
      override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {

        if editingStyle == .delete {
            self.database.context.delete(dataArray[indexPath.row])
            dataArray.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
            self.database.savePassedData()
            tableView.reloadData()
            }
        }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToScanDetails" {
            let detailsVC = segue.destination as! ScanDetailsController
            
            if let indexPath = tableView.indexPathForSelectedRow {
                detailsVC.seletectedItem = dataArray[indexPath.row]
                detailsVC.currentSheetforUploadDetails = currentSheetforUpload
                ScanDetailsController.deleteDelegate = self

            }
        }
    }

    func deleteScannedData(data: [ScannedData], uploaded: Bool) {
 
        dataToDelete = data
          isUploaded = uploaded
        if let indexPath = tableView.indexPathForSelectedRow{

            self.database.context.delete(dataToDelete![indexPath.row])
            dataArray.remove(at: indexPath.row)
            self.database.savePassedData()
            tableView.reloadData()
            }
    }

}

extension ScanHistoryController {
    
    func loadPassedData() {

        let request : NSFetchRequest<ScannedData> = ScannedData.fetchRequest()

        do{
            dataArray = try database.context.fetch(request)
        } catch {
            print("Error loading categories \(error)")
        }
        tableView.reloadData()
    }
}
