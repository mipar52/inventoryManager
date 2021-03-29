//
//  MainScreenController.swift
//  InventoryManager
//
//  Created by Milan Parađina on 25.03.2021..
//

import UIKit
import Microblink
import GoogleSignIn
import GoogleAPIClientForREST
import GTMSessionFetcher
import Toast_Swift

class MainScreenController: UIViewController {
    
    @IBOutlet weak var signInButton: UIButton!
    
    let sheetBrain = SheetBrain()
    let dbBrain = DataBaseBrain()
    let utils = Utils()
    
    let key = "key-obtained-from-Microblink"
    var barcodeRecognizer : MBBarcodeRecognizer?
    
    private let service = GTLRSheetsService()
    private let driveService = GTLRDriveService()
    private let scopes = [kGTLRAuthScopeSheetsSpreadsheets, kGTLRAuthScopeSheetsDrive]
    private let driveScopes = [kGTLRAuthScopeSheetsDrive]
    
    let defaults = UserDefaults.standard
    var resultSucess: Bool?
    var infoForVC : String?
    var passedData : [String]?
    var observer : NSObjectProtocol?
    var currentUser = "email"
    var isLicenseValid = true

    override func viewDidLoad() {
        super.viewDidLoad()
        
        MBMicroblinkSDK.shared().setLicenseKey(key) { (error) in
            self.isLicenseValid = false
        }
            
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().scopes = scopes

        GIDSignIn.sharedInstance()?.signIn()
        
        currentUser = (defaults.object(forKey: "userId") as? String ?? "email")
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleNotif), name: .sheetIdNotificationKey, object: nil)
  
    
    }
      
    @IBAction func scanPressed(_ sender: UIButton) {
        if isLicenseValid == true {
        let autoUpload = defaults.object(forKey: "isuploadAuto") as? Bool ?? false
        print("Autoupload is: \(autoUpload)")
        
        self.barcodeRecognizer = MBBarcodeRecognizer()
        self.barcodeRecognizer?.scanQrCode = true

        let settings: MBBarcodeOverlaySettings = MBBarcodeOverlaySettings()

        let recognizerList = [self.barcodeRecognizer!]
        let recognizerCollection: MBRecognizerCollection = MBRecognizerCollection(recognizers: recognizerList)

        let barcodeOverlayViewController: MBBarcodeOverlayViewController =
            MBBarcodeOverlayViewController(settings: settings, recognizerCollection: recognizerCollection, delegate: self)

        guard let recognizerRunneViewController: UIViewController =
                MBViewControllerFactory.recognizerRunnerViewController(withOverlayViewController: barcodeOverlayViewController) else {
                       return
               }
        
        observer = NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "uploadPressed"), object: nil, queue: OperationQueue.main) { (notification) in
            
            let vc = notification.object as! OverlayView
            
            let splitResults = vc.results?.components(separatedBy: ";")
           
            let data : Array<Any>.ArrayLiteralElement = splitResults

            if vc.dataSent == true {
                self.sheetBrain.sendDataToSheet(results: data as! Array<[Any]>.ArrayLiteralElement, failedData: vc.results) { (sentBool) in
                    if sentBool == false {
                    print("Fail!")
                        self.utils.addToast(messageColor: .black, backgroundColor: #colorLiteral(red: 0.9098039269, green: 0.4784313738, blue: 0.6431372762, alpha: 1), message: "Upload failed.\nSaving the data...", vc: barcodeOverlayViewController)
    
                    } else if sentBool {
                        print("Sucess!")
                        self.utils.addToast(messageColor: .black, backgroundColor: #colorLiteral(red: 0.4, green: 0.8509803922, blue: 0.7882352941, alpha: 1), message: "Upload sucessful!", vc: barcodeOverlayViewController)
                        }
                }

            } else if vc.dataSent == false {
                self.utils.addToast(messageColor: .black, backgroundColor: #colorLiteral(red: 0.6666666865, green: 0.6666666865, blue: 0.6666666865, alpha: 1), message: "Dissmissed..\nSaving the data..", vc: barcodeOverlayViewController)
            }
            
            self.utils.run(after: 2) {
                barcodeOverlayViewController.recognizerRunnerViewController?.resumeScanningAndResetState(true)
                }
        }
        sheetBrain.showSheetNameToVc(VC: barcodeOverlayViewController, position: .bottom)
        recognizerRunneViewController.modalPresentationStyle = .fullScreen
        
        self.present(recognizerRunneViewController, animated: true, completion: nil)
            
        } else {
            self.utils.showAlert(title: "Error", message: "Can't access the SDK!\nCheck if you've entered the correct license key..", vc: self)
        }
    }

    @IBAction func signInPressed(_ sender: UIButton) {
        print("Sign in pressed")
        
        if self.service.authorizer == nil{
        GIDSignIn.sharedInstance()?.signIn()
            print("signing in....")
        } else if (self.service.authorizer != nil) {
            GIDSignIn.sharedInstance()?.signOut()
            self.service.authorizer = nil
            
            sender.setTitle("Sign in", for: UIControl.State.normal)
            sender.setTitleColor(#colorLiteral(red: 0.2745098174, green: 0.4862745106, blue: 0.1411764771, alpha: 1), for: UIControl.State.normal)
            print("signing out....")
        }
    }
    
    @objc func handleNotif(notification: NSNotification){
        let idVC = notification.object as! SheetDetailsController
        sheetBrain.passedSpreadsheetId = idVC.selectedSheet?.spreadsheetId
        sheetBrain.passedSheetName = "\"\(String(describing:idVC.selectedSheet!.spreadsheetName!))\"\n(\(idVC.currentSheetName!))"
        sheetBrain.passedId = idVC.currentSheetName
        
        defaults.set(sheetBrain.passedSheetName, forKey: "sheetBrainName")
        defaults.set(sheetBrain.passedSpreadsheetId, forKey: "sheetBrainId")
        defaults.set(sheetBrain.passedId, forKey: "passedSheetId")
    }
    
    @objc func showHalfVC(blinkIdOverlayViewController: MBBarcodeOverlayViewController) {
        let slideVC = OverlayView()
        slideVC.results = infoForVC!
        slideVC.modalPresentationStyle = .custom
        slideVC.transitioningDelegate = self
        blinkIdOverlayViewController.present(slideVC, animated: true, completion: nil)
    }

}

extension MainScreenController: MBBarcodeOverlayViewControllerDelegate, GIDSignInDelegate, GIDSignInUIDelegate  {

      func barcodeOverlayViewControllerDidFinishScanning(_ barcodeOverlayViewController: MBBarcodeOverlayViewController, state: MBRecognizerResultState) {
        
        let autoUpload = defaults.object(forKey: "isuploadAuto") as? Bool ?? false
        barcodeOverlayViewController.recognizerRunnerViewController?.pauseScanning()
            var message: String = ""
        
            if self.barcodeRecognizer?.result.resultState == MBRecognizerResultState.valid {
                message = self.barcodeRecognizer!.result.stringData!
                var splitMessage = message.components(separatedBy: ";")
                let lastElement = (splitMessage.last?.replacingOccurrences(of: ";", with: ""))!
                splitMessage.removeLast()
                splitMessage.append(lastElement)
                
                let data : Array<Any>.ArrayLiteralElement = splitMessage
                /** Needs to be called on main thread beacuse everything prior is on background thread */
                infoForVC = message
                if autoUpload == false {
                DispatchQueue.main.async {
                    
                self.infoForVC = message
                
                self.showHalfVC(blinkIdOverlayViewController: barcodeOverlayViewController)
                    }
                } else if autoUpload == true {
                    
                    DispatchQueue.main.async {
                        self.sheetBrain.sendDataToSheet(results: data as! Array<[Any]>.ArrayLiteralElement, failedData: message) { (sentBool) in
                            if sentBool == false {
                            self.utils.addToast(messageColor: .black, backgroundColor: #colorLiteral(red: 0.9098039269, green: 0.4784313738, blue: 0.6431372762, alpha: 1), message: "Upload failed. \nSaving the data...", vc: barcodeOverlayViewController)

                            } else if sentBool == true {
                                self.utils.addToast(messageColor: .black, backgroundColor: #colorLiteral(red: 0.4, green: 0.8509803922, blue: 0.7882352941, alpha: 1), message: "Upload sucessful!", vc: barcodeOverlayViewController)
                                }
                        }
                    
                    self.utils.run(after: 3) {
                        barcodeOverlayViewController.recognizerRunnerViewController?.resumeScanningAndResetState(true)
                    }
                }
            }
        }
    }

    func barcodeOverlayViewControllerDidTapClose(_ barcodeOverlayViewController: MBBarcodeOverlayViewController) {
            self.dismiss(animated: true, completion: nil)
        }
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!,
              withError error: Error!) {
        if let error = error {
            self.service.authorizer = nil
            self.driveService.authorizer = nil
            print(error)
        } else {
            self.driveService.authorizer = user.authentication.fetcherAuthorizer()
            self.service.authorizer = user.authentication.fetcherAuthorizer()
            signInButton.setTitle("Sign out", for: UIControl.State.normal)
            signInButton.setTitleColor(#colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1), for: UIControl.State.normal)
            let id = user.profile.email
           if currentUser != id {
            print("Current user is \(id)")
            defaults.set(id, forKey: "userId")
            currentUser = (defaults.object(forKey: "userId") as! String)
                askForDriveSheets()
            } else {
                return
                }
            }
        }
    func askForDriveSheets() {
    
        let sheetDriveAlert = UIAlertController(title: "Drive Spreadsheets", message: "Would you like to add Google Spreadsheets from your Google Drive?", preferredStyle: .alert)
        
        let okay = UIAlertAction(title: "Yes", style: .default) { (action) in

            self.utils.ncSpin(message: "Getting Sheets..", vc: self.navigationController!)
            self.sheetBrain.findDriveSheets { (bool) in
                self.dismiss(animated: true) {
                    if bool == true {
                        self.performSegue(withIdentifier: "goToSpreadsheets", sender: self)
                    } else {
                        self.utils.showAlert(title: "Error", message: "Could not load Spreadsheets! \n1. See if you are connected to the Internet \n2. Check if you are properly signed into your Google Account.", vc: self)
                    }
                }
            }
        }
        let nah = UIAlertAction(title: "No", style: .default) { (action) in
            self.dismiss(animated: true, completion: nil)
        }
        
        sheetDriveAlert.addAction(okay)
        sheetDriveAlert.addAction(nah)
        self.present(sheetDriveAlert, animated: true, completion: nil)

        }
    }

extension MainScreenController : UIViewControllerTransitioningDelegate {
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return PresentationController(presentedViewController: presented, presenting: presenting)
    }
}
