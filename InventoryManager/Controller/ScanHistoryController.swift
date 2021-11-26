//
//  ScanHistoryController.swift
//  InventoryManager
//
//  Created by Milan Parađina on 25.03.2021..
//

import UIKit
import CoreData

class ScanHistoryController: UITableViewController, DataDeleteDelegate  {
  
    let sheetBrain = SheetBrain()
    let database = DataBaseBrain()
    let utils = Utils()
    let defaults = UserDefaults.standard
    var dataArray = [ScannedData]()
    var dataToDelete : [ScannedData]?
    var isUploaded: Bool?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView()
        utils.addToast(backgroundColor: K.colors.neutral, message: "Sheet for upload:\n\(defaults.string(forKey: K.uDefaults.toastSheetName)!)", vc: self.navigationController!)
        self.loadScannedData()
        self.refreshControl?.addTarget(self, action: #selector(refresh), for: UIControl.Event.valueChanged)
    }
    override func viewWillAppear(_ animated: Bool) {
         super.viewWillAppear(animated)
        if isUploaded == true {
            self.utils.showAlert(title: K.popupStrings.alert.success, message: K.popupStrings.alert.dataUploaded, vc: self)
            isUploaded = nil
            self.loadScannedData()
            tableView.reloadData()
            } else if isUploaded == false{
              self.utils.showAlert(title: K.popupStrings.alert.success, message: K.popupStrings.alert.dataDeleted, vc: self)
              isUploaded = nil
              self.loadScannedData()
              tableView.reloadData()
            }
     }
        
    @IBAction func uploadAllPressed(_ sender: UIBarButtonItem) {
        if self.dataArray.count == 0 {
            self.utils.showAlert(title: K.popupStrings.alert.noData, message: K.popupStrings.alert.noDataSent, vc: self)
        } else {
            if self.dataArray.count == 1 {
                self.utils.showSpinner(message: K.popupStrings.spinner.uploadingItem, vc: self)
            } else if self.dataArray.count > 1 {
                self.utils.showSpinner(message: "Uploading \(self.dataArray.count) items..", vc: self)
            }
            var multiResults: [[String]] = [[]]
            for element in self.dataArray {
                multiResults.removeAll()
                let item = element.scannedData
                let parsedItem = item?.components(separatedBy: ";")
                multiResults.append(parsedItem!)
            }
            let data : Array<Any>.ArrayLiteralElement = multiResults
            self.sheetBrain.sendMulitpleRequests(results: data) { (bool) in
                if bool == true {
                    self.database.deleteAllData(entity: "ScannedData") { success in
                        self.database.savePassedData()
                        self.loadScannedData()
                    }
                    self.dismiss(animated: true) {
                    self.utils.showAlert(title: K.popupStrings.alert.success, message: K.popupStrings.alert.complete, vc: self)
                    }
            } else {
              self.dismiss(animated: true) {
              self.utils.showAlert(title: K.popupStrings.alert.error, message: K.popupStrings.alert.uploadFailed, vc: self)
              }
            }
          }
        }
    }
    
    @IBAction func deleteAllPressed(_ sender: UIBarButtonItem) {
        self.utils.addTwoActionAlert(title: K.popupStrings.alert.delete, message: K.popupStrings.alert.deleteAllDataAction, actionTitle: K.popupStrings.alert.yes, vc: self) { action in
            self.utils.showSpinner(message: K.popupStrings.spinner.deletingAllData, vc: self)
            self.database.deleteAllData(entity: "ScannedData") { success in
                self.dismiss(animated: true) {
                    if success == true {
                        self.utils.showAlert(title: K.popupStrings.alert.success, message: K.popupStrings.alert.allDataDeleted, vc: self)
                    } else {
                        self.utils.showAlert(title: K.popupStrings.alert.success, message: K.popupStrings.alert.allDataDeleteError, vc: self)
                    }
                    self.loadScannedData()
                }
            }
        }
    }
    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArray.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: K.identifiers.cell, for: indexPath)
        let info = dataArray[indexPath.row]
        let parsedInfo = info.scannedData?.components(separatedBy: ";")
            cell.textLabel?.text = "\(parsedInfo?[0] ?? "No data")"
            cell.detailTextLabel?.text = info.scanDate
            cell.accessoryType = .disclosureIndicator
        return cell
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50.0
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
        if segue.identifier == K.segues.scanDetails {
            let detailsVC = segue.destination as! ScanDetailsController
            if let indexPath = tableView.indexPathForSelectedRow {
                detailsVC.seletectedItem = dataArray[indexPath.row]
                ScanDetailsController.deleteDelegate = self
            }
        }
    }
    @objc func refresh(sender:AnyObject){
        self.loadScannedData()
        self.refreshControl?.endRefreshing()
    }
}

extension ScanHistoryController {
    func loadScannedData() {
        let request : NSFetchRequest<ScannedData> = ScannedData.fetchRequest()
        do{
            dataArray = try self.database.context.fetch(request)
        } catch {
            print("Error loading categories \(error)")
        }
        tableView.reloadData()
    }

    func deleteScannedData(data: [ScannedData], uploaded: Bool) {
        isUploaded = uploaded
        if let indexPath = tableView.indexPathForSelectedRow{
            self.database.context.delete(data[indexPath.row])
            dataArray.remove(at: indexPath.row)
            self.database.savePassedData()
            tableView.reloadData()
        }
    }
}
