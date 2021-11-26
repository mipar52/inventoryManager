//
//  ScanBrain.swift
//  InventoryManager
//
//  Created by Milan Parađina on 12.11.2021..
//

import Foundation
import Pdf417Mobi

class ScanBrain {
    
    let defaults = UserDefaults.standard
    let utils = Utils()
    let sheetBrain = SheetBrain()
    
    var isKeyValid = true
    var observer : NSObjectProtocol?
    var barcodeRecognizer : MBBBarcodeRecognizer?
    
    func setupLicenseKey() {
        MBBMicroblinkSDK.shared().setLicenseKey(K.keys.microblinkKey) { (error) in
        self.isKeyValid = false
        }
    }
    
    func setupPdf417 (vc: UIViewController) {
        if isKeyValid == true {
        let autoUpload = defaults.object(forKey: "isuploadAuto") as? Bool ?? false
        print("Autoupload is: \(autoUpload)")
        barcodeRecognizer = MBBBarcodeRecognizer()
        barcodeRecognizer?.scanQrCode = true

        let settings: MBBBarcodeOverlaySettings = MBBBarcodeOverlaySettings()
        let recognizerList = [self.barcodeRecognizer!]
        let recognizerCollection: MBBRecognizerCollection = MBBRecognizerCollection(recognizers: recognizerList)
        let barcodeOverlayViewController: MBBBarcodeOverlayViewController =
            MBBBarcodeOverlayViewController(settings: settings, recognizerCollection: recognizerCollection, delegate: vc as! MBBBarcodeOverlayViewControllerDelegate)
        guard let recognizerRunneViewController: UIViewController =
                MBBViewControllerFactory.recognizerRunnerViewController(withOverlayViewController: barcodeOverlayViewController) else {
                       return
               }
        observer = NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "uploadPressed"), object: nil, queue: OperationQueue.main) { (notification) in
            let vc = notification.object as! OverlayView
            let splitResults = vc.results?.components(separatedBy: ";")
            let data : Array<Any>.ArrayLiteralElement = splitResults
            if vc.dataSent == true {
                self.sheetBrain.sendDataToSheet(results: data as! Array<[Any]>.ArrayLiteralElement, failedData: vc.results) { (sentBool) in
                    if sentBool == false {
                        self.utils.addToast(backgroundColor: K.colors.error, message: K.popupStrings.toast.errorDataSave, vc: barcodeOverlayViewController)
                    } else if sentBool {
                        self.utils.addToast(backgroundColor: K.colors.success, message: K.popupStrings.toast.successUpload, vc: barcodeOverlayViewController)
                        }
                }
            } else if vc.dataSent == false {
                self.utils.addToast(backgroundColor: K.colors.neutral, message: K.popupStrings.toast.dissmissed, vc: barcodeOverlayViewController)
            }
            self.utils.run(after: 2) {
                barcodeOverlayViewController.recognizerRunnerViewController?.resumeScanningAndResetState(true)
                }
        }
        utils.addToast(backgroundColor: K.colors.neutral, message: defaults.string(forKey: K.uDefaults.toastSheetName)!, vc: barcodeOverlayViewController)
        recognizerRunneViewController.modalPresentationStyle = .fullScreen
        vc.present(recognizerRunneViewController, animated: true, completion: nil)
        } else {
            utils.showAlert(title: K.popupStrings.alert.error, message: K.popupStrings.alert.mbLicenseError, vc: vc)
        }
    }
}
