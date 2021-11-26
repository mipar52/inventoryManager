//
//  MainScreenController.swift
//  InventoryManager
//
//  Created by Milan Parađina on 25.03.2021..
//

import UIKit
import Pdf417Mobi

class MainScreenController: UIViewController {
        
    let sheetBrain = SheetBrain()
    let dbBrain = DataBaseBrain()
    let scanBrain = ScanBrain()
    let accountBrain = SignInBrain()
    let utils = Utils()
    
    let defaults = UserDefaults.standard
    var resultSucess: Bool?
    var infoForVC : String?
    var passedData : [String]?
    var sheetId : String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        accountBrain.googleSignIn(vc: self) { success, user  in
            if success == true {
                self.utils.addToast(backgroundColor: K.colors.success, message: K.accountStrings.signInString , vc: self)
            } else {
                self.utils.addToast(backgroundColor: K.colors.error, message: K.accountStrings.signInIssues, vc: self)
            }
        }
        scanBrain.setupLicenseKey()
    }
      
    @IBAction func scanPressed(_ sender: UIButton) {
        sheetId = defaults.string(forKey: K.uDefaults.spreadsheetId)
        if sheetId != nil {
            self.scanBrain.setupPdf417(vc: self)
        } else {
            self.utils.showAlert(title: K.popupStrings.alert.error, message: K.popupStrings.alert.firstSpreadsheet, vc: self)
        }
        
    }
    
    @objc func showHalfVC(blinkIdOverlayViewController: MBBBarcodeOverlayViewController) {
        let slideVC = OverlayView()
        slideVC.results = infoForVC!
        slideVC.modalPresentationStyle = .custom
        slideVC.transitioningDelegate = self
        blinkIdOverlayViewController.present(slideVC, animated: true, completion: nil)
    }

}

extension MainScreenController: MBBBarcodeOverlayViewControllerDelegate {

      func barcodeOverlayViewControllerDidFinishScanning(_ barcodeOverlayViewController: MBBBarcodeOverlayViewController, state: MBBRecognizerResultState) {
        
          let autoUpload = defaults.object(forKey: K.uDefaults.isuploadAuto) as? Bool ?? false
        barcodeOverlayViewController.recognizerRunnerViewController?.pauseScanning()
            var qrCodeResults: String = ""
        
          if self.scanBrain.barcodeRecognizer?.result.resultState == MBBRecognizerResultState.valid {
              qrCodeResults = self.scanBrain.barcodeRecognizer!.result.stringData!
                var splitResults = qrCodeResults.components(separatedBy: ";")
                let lastElement = (splitResults.last?.replacingOccurrences(of: ";", with: ""))!
              splitResults.removeLast()
              splitResults.append(lastElement)
                
                let data : Array<Any>.ArrayLiteralElement = splitResults
                /** Needs to be called on main thread beacuse everything prior is on background thread */
                infoForVC = qrCodeResults
                if autoUpload == false {
                DispatchQueue.main.async {
                self.infoForVC = qrCodeResults
                self.showHalfVC(blinkIdOverlayViewController: barcodeOverlayViewController)
                    }
                } else if autoUpload == true {
                    
                    DispatchQueue.main.async {
                        self.sheetBrain.sendDataToSheet(results: data as! Array<[Any]>.ArrayLiteralElement, failedData: qrCodeResults) { (sentBool) in
                            if sentBool == false {
                                self.utils.addToast(backgroundColor: K.colors.error, message: K.popupStrings.toast.errorDataSave, vc: barcodeOverlayViewController)
                            } else if sentBool == true {
                                self.utils.addToast(backgroundColor: K.colors.success, message:K.popupStrings.toast.successUpload, vc: barcodeOverlayViewController)
                                }
                        }
                    self.utils.run(after: 3) {
                        barcodeOverlayViewController.recognizerRunnerViewController?.resumeScanningAndResetState(true)
                    }
                }
            }
        }
    }

    func barcodeOverlayViewControllerDidTapClose(_ barcodeOverlayViewController: MBBBarcodeOverlayViewController) {
            self.dismiss(animated: true, completion: nil)
        }
    }

extension MainScreenController : UIViewControllerTransitioningDelegate {
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return PresentationController(presentedViewController: presented, presenting: presenting)
    }
}
