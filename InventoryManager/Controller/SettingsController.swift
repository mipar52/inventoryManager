//
//  SettingsController.swift
//  InventoryManager
//
//  Created by Milan Parađina on 25.03.2021..
//
import UIKit

class SettingsController: UITableViewController {
    
    @IBOutlet weak var sheetCell: UITableViewCell!
    @IBOutlet weak var driveCell: UITableViewCell!
    @IBOutlet weak var scanContinueCell: UITableViewCell!
    @IBOutlet weak var uploadAutoCell: UITableViewCell!
    @IBOutlet weak var scanConSwitch: UISwitch!
    @IBOutlet weak var autoUploadSwitch: UISwitch!
    
    let sheetBrain = SheetBrain()
    let utils = Utils()
    
    let defaults = UserDefaults.standard
    var isScanContinue : Bool?
    var isuploadAuto: Bool?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        sheetCell.textLabel?.text = "Spreadsheets"
        sheetCell.accessoryType = .disclosureIndicator
        
        driveCell.textLabel?.text = "Check Google Drive for new Spreadsheets"
        driveCell.textLabel?.adjustsFontSizeToFitWidth = true
        
        scanContinueCell.textLabel?.text = "Scan contiously"
        uploadAutoCell.textLabel?.text = "Upload automatically"
        
        scanConSwitch.isOn = defaults.object(forKey: "scSwitchisOn") as? Bool ?? false
        autoUploadSwitch.isOn = defaults.object(forKey: "aUploadisOn") as? Bool ?? false
        
        }

    override func viewWillDisappear(_ animated: Bool) {
        defaults.set(scanConSwitch.isOn, forKey: "scSwitchisOn")
        defaults.set(autoUploadSwitch.isOn, forKey: "aUploadisOn")
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0  && indexPath.row == 0{
                performSegue(withIdentifier: "goToSheets", sender: self)
            
        } else if indexPath.section == 0 && indexPath.row == 1 {

            self.utils.ncSpin(message: "Getting Sheets..", vc: self.navigationController!)
            sheetBrain.findDriveSheets { (bool) in
                self.dismiss(animated: true) {
                    if bool == true {
                        print("In settings, \(self.sheetBrain.driveSheetNumber) is Sheet Number!")
                        if self.sheetBrain.driveSheetNumber == 0 {
                            self.utils.showAlert(title: "Sheets", message: "All Sheets already added!", vc: self)
                            self.sheetBrain.driveSheetNumber = 0
                        } else if self.sheetBrain.driveSheetNumber == 1{
                            self.utils.showAlert(title: "Sheets", message: "Added \(self.sheetBrain.driveSheetNumber) sheet!", vc: self)
                            self.sheetBrain.driveSheetNumber = 0
                            print("Reset: \(self.sheetBrain.driveSheetNumber)")
                        }  else if self.sheetBrain.driveSheetNumber > 0 {
                            self.utils.showAlert(title: "Sheets", message: "Added \(self.sheetBrain.driveSheetNumber) sheets!", vc: self)
                            self.sheetBrain.driveSheetNumber = 0
                            print("Reset: \(self.sheetBrain.driveSheetNumber)")
                        }
                    } else {
                        self.utils.showAlert(title: "Error", message: "Could not load Spreadsheets! \n1. See if you are connected to the Internet \n2. Check if you are properly signed into your Google Account.", vc: self)
                    }
                }
            }
        }
        tableView.deselectRow(at: indexPath, animated: false)
    }

    @IBAction func scanContiueSwitchPressed(_ sender: UISwitch) {
        print("scan pressed")
        if sender.isOn {
            isScanContinue = true
        } else {
            isScanContinue = false
        }
        defaults.set(isScanContinue, forKey: "isScanContinue")
        print(isScanContinue as Any)
    }
    
    
    @IBAction func uploadAutoSwitchPressed(_ sender: UISwitch) {
        print("auto pressed")
        
        if sender.isOn {
            isuploadAuto = true
        } else {
            isuploadAuto = false
        }
        defaults.set(isuploadAuto, forKey: "isuploadAuto")

        print("Scan auto is: \(String(describing: isuploadAuto))")
    }
}
