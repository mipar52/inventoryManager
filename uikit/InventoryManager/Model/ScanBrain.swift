//
//  ScanBrain.swift
//  InventoryManager
//
//  Created by Milan Parađina on 12.11.2021..
//

import Foundation
import AVFoundation
import UIKit

class ScanBrain {
    
    let defaults = UserDefaults.standard
    let utils = Utils()
    let sheetBrain = SheetBrain()
    
    var observer : NSObjectProtocol?
    
    func prepareObserver(_ scanningVc: UIViewController, _ captureSession: AVCaptureSession?) {
        let autoUpload = defaults.object(forKey: "isuploadAuto") as? Bool ?? false
        print("Autoupload is: \(autoUpload)")
        
        observer = NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "uploadPressed"), object: nil, queue: OperationQueue.main) { (notification) in
            
            let vc = notification.object as! OverlayView
            let splitResults = vc.results?.components(separatedBy: "\n")
            let data : Array<Any>.ArrayLiteralElement = splitResults
            
            if vc.dataSent == true {
                self.sheetBrain.sendDataToSheet(results: data as! Array<[Any]>.ArrayLiteralElement, failedData: vc.results) { (sentBool) in
                    if sentBool == false {
                        self.utils.addToast(backgroundColor: K.colors.error, message: K.popupStrings.toast.errorDataSave, vc: scanningVc)
                    } else if sentBool {
                        self.utils.addToast(backgroundColor: K.colors.success, message: K.popupStrings.toast.successUpload, vc: scanningVc)
                        }
                }
            } else if vc.dataSent == false {
                self.utils.addToast(backgroundColor: K.colors.neutral, message: K.popupStrings.toast.dissmissed, vc: scanningVc)
            }
            self.observer = nil

            self.utils.run(after: 1) {
                DispatchQueue.global(qos: .background).async {
                    captureSession?.startRunning()
                }
                }
        }
    }
}
