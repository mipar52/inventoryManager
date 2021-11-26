//
//  SettingsController.swift
//  InventoryManager
//
//  Created by Milan Parađina on 25.03.2021..
//
import UIKit
import GoogleSignIn

class SettingsController: UITableViewController {
    
    @IBOutlet weak var accountCell: UITableViewCell!
    @IBOutlet weak var sheetCell: UITableViewCell!
    @IBOutlet weak var driveCell: UITableViewCell!
    @IBOutlet weak var deleteCell: UITableViewCell!
    @IBOutlet weak var scanContinueCell: UITableViewCell!
    @IBOutlet weak var uploadAutoCell: UITableViewCell!
    @IBOutlet weak var scanConSwitch: UISwitch!
    @IBOutlet weak var autoUploadSwitch: UISwitch!
    @IBOutlet weak var autoUploadTitle: UILabel!
    @IBOutlet weak var scanContiueTitle: UILabel!
    @IBOutlet weak var scanContinueSubtitle: UILabel!
    @IBOutlet weak var autoUploadSubtitle: UILabel!
    
    let accountBrain = SignInBrain()
    let sheetBrain = SheetBrain()
    let driveBrain = DriveBrain()
    let utils = Utils()
    let database = DataBaseBrain()
    let defaults = UserDefaults.standard
    
    var isScanContinue : Bool?
    var isuploadAuto: Bool?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.accountBrain.googleSignIn(vc: self) { success, user  in
            if success == true {
                self.adjustSignInCell(user: user!)
            } else {
                self.accountCell.textLabel?.text = K.accountStrings.signInIssuesCell
            }
        }
       adjustCells()
    }

    override func viewWillDisappear(_ animated: Bool) {
        defaults.set(scanConSwitch.isOn, forKey: K.uDefaults.scSwitchisOn)
        defaults.set(autoUploadSwitch.isOn, forKey: K.uDefaults.aUploadisOn)
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0  && indexPath.row == 0 {
            let user = GIDSignIn.sharedInstance.currentUser
            if (user == nil) {
            self.accountBrain.googleSignIn(vc: self) { success, user  in
                    if success == true {
                        self.accountCell.textLabel?.text = "\(user?.profile?.email)"
                    } else {
                        self.accountCell.textLabel?.text = K.accountStrings.signInIssuesCell
                    }
                }
               } else {
                   GIDSignIn.sharedInstance.signOut()
                   self.accountCell.textLabel?.text = K.accountStrings.singOutTap
            }
        }
        if indexPath.section == 1  && indexPath.row == 0{
            performSegue(withIdentifier: K.segues.goToSheets, sender: self)
        } else if indexPath.section == 1 && indexPath.row == 1 {
            self.utils.addTwoActionAlert(title: K.popupStrings.alert.addSpreads, message: K.popupStrings.alert.addSpreadAction, actionTitle: K.popupStrings.alert.yes, vc: self) { action in
                self.utils.showSpinner(message: K.popupStrings.spinner.gettingSheets, vc: self.navigationController!)
                self.driveBrain.findDriveSheets { (success, counter) in
                    self.dismiss(animated: true) {
                        if success == true {
                            if counter! == 0 {
                                self.utils.showAlert(title: K.UIStrings.sheets, message: K.popupStrings.alert.spreadAlreadyAdded, vc: self)
                            } else if counter! == 1{
                                self.utils.showAlert(title: K.UIStrings.sheets, message: K.popupStrings.alert.addedOneSheet, vc: self)
                            }  else if counter! > 0 {
                                self.utils.showAlert(title: K.UIStrings.sheets, message: "Added \(counter!) sheets!", vc: self)
                            }
                        } else {
                            self.utils.showAlert(title: K.popupStrings.alert.error, message: K.popupStrings.alert.errorGetSpread, vc: self)
                        }
                    }
                }
            }
        } else if indexPath.section == 1 && indexPath.row == 2 {
            self.utils.addTwoActionAlert(title: K.popupStrings.alert.delete, message: K.popupStrings.alert.deleteAllSheetDataAction, actionTitle: K.popupStrings.alert.yes, vc: self) { action in
                self.utils.showSpinner(message: K.popupStrings.spinner.deletingAllData, vc: self)
                self.database.deleteAllData(entity: "Spreadsheet") { success in
                    self.dismiss(animated: true) {
                        if success == true {
                            self.utils.showAlert(title: K.popupStrings.alert.success, message: K.popupStrings.alert.allDataDeleted, vc: self)
                        } else {
                            self.utils.showAlert(title: K.popupStrings.alert.error, message: K.popupStrings.alert.allDataDeleteError, vc: self)
                        }
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
        defaults.set(isScanContinue, forKey: K.uDefaults.isScanContinue)
        print(isScanContinue as Any)
    }
    
    @IBAction func uploadAutoSwitchPressed(_ sender: UISwitch) {
        print("auto pressed")
        if sender.isOn {
            isuploadAuto = true
        } else {
            isuploadAuto = false
        }
        defaults.set(isuploadAuto, forKey: K.uDefaults.isuploadAuto)
        print("Scan auto is: \(String(describing: isuploadAuto))")
    }
}
extension SettingsController {
  func adjustSignInCell (user: GIDGoogleUser) {
       let id = user.profile?.name
       let dim = (self.accountCell.imageView?.frame.size.width)! / 2
       let dimension = round(dim * UIScreen.main.scale)
       let pic = user.profile?.imageURL(withDimension: UInt(dimension))
       self.accountCell.textLabel?.adjustsFontSizeToFitWidth = true
       self.accountCell.textLabel?.text = "\(id!)"
       self.utils.downloadImage(from: pic!, completionHandler: { (data) in
            DispatchQueue.main.async {
            let userPic = UIImage(data: data)
            self.accountCell.imageView?.image = self.utils.imageWithImage(image: userPic!, scaledToSize: CGSize(width: 35, height: 35))
            self.accountCell.imageView?.layer.cornerRadius = 17.5 //(self.signInCell.imageView?.frame.size.width)! / 2
            self.accountCell.imageView!.layer.masksToBounds = true
            self.accountCell.textLabel?.text = "\(id!)"
            self.tableView.reloadData()
            }
        })
    }
        
  func adjustCells() {
       sheetCell.textLabel?.text = K.UIStrings.spreadsheets
       sheetCell.accessoryType = .disclosureIndicator
       driveCell.textLabel?.text = K.UIStrings.googleDrive
       driveCell.textLabel?.adjustsFontSizeToFitWidth = true
       deleteCell.textLabel?.text = K.UIStrings.deleteCell
       deleteCell.textLabel?.textColor = K.colors.error
       deleteCell.textLabel?.adjustsFontSizeToFitWidth = true
       scanContiueTitle.text = K.UIStrings.scanContinue
       scanContinueCell.detailTextLabel?.text = K.UIStrings.scanContinueDetail
       autoUploadTitle.text = K.UIStrings.uploadAuto
       uploadAutoCell.detailTextLabel?.text = K.UIStrings.uploadAutoDetail
       autoUploadSubtitle.text = K.UIStrings.uploadAutoDetail
       scanContinueSubtitle.text = K.UIStrings.scanContinueDetail
       scanConSwitch.isOn = defaults.object(forKey: "scSwitchisOn") as? Bool ?? false
       autoUploadSwitch.isOn = defaults.object(forKey: "aUploadisOn") as? Bool ?? false
    }
}
