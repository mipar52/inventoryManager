//
//  Utils.swift
//  InventoryManager
//
//  Created by Milan Parađina on 25.03.2021..
//

import Foundation
import Toast_Swift

class Utils {
    
    var isURLValid : Bool?
    
    
    func addToast(messageColor: UIColor, backgroundColor: UIColor, message: String, vc: UIViewController) {
         var style = ToastStyle()
         style.messageColor = messageColor
         style.backgroundColor = backgroundColor
        style.messageAlignment = .center
         vc.view.makeToast(message, duration: 2.0, position: .bottom, style: style)
         }
     
    func addToastToNC(messageColor: UIColor, backgroundColor: UIColor, message: String, nc: UINavigationController) {
         var style = ToastStyle()
         style.messageColor = messageColor
         style.backgroundColor = backgroundColor
        style.messageAlignment = .center
             
         nc.view.makeToast(message, duration: 2.0, position: .bottom, style: style)
         }
     
     func showAlert(title : String, message: String, vc: UIViewController) {
          let alert = UIAlertController(
                  title: title,
                  message: message,
                  preferredStyle: UIAlertController.Style.alert
          )
          let ok = UIAlertAction(
                  title: "OK",
                  style: UIAlertAction.Style.default,
                  handler: nil
          )
          alert.addAction(ok)
         vc.present(alert, animated: true, completion: nil)
      }
    func showSpinner(message: String, vc: UIViewController) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 40, height: 50))
        alert.preferredContentSize = CGSize(width: 200.0, height: 100.0)
        
        loadingIndicator.style = UIActivityIndicatorView.Style.medium
        
        loadingIndicator.startAnimating();

        alert.view.addSubview(loadingIndicator)
        vc.present(alert, animated: true, completion: nil)

    }
    
    func ncSpin(message: String, vc: UINavigationController) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 40, height: 50))
        alert.preferredContentSize = CGSize(width: 200.0, height: 100.0)
        loadingIndicator.style = UIActivityIndicatorView.Style.medium
        
        loadingIndicator.startAnimating();

        alert.view.addSubview(loadingIndicator)
        vc.present(alert, animated: true, completion: nil)
    }
    
    func boolSpinner(message: String, shouldStop: Bool, vc: UIViewController, completionHandler: @escaping () -> Void) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 40, height: 50))
        alert.preferredContentSize = CGSize(width: 200.0, height: 100.0)
        loadingIndicator.style = UIActivityIndicatorView.Style.medium
        
        loadingIndicator.startAnimating();

        alert.view.addSubview(loadingIndicator)
        vc.present(alert, animated: true, completion: nil)
        
        if shouldStop == true {
            loadingIndicator.stopAnimating();
            vc.dismiss(animated: false, completion: nil)
            completionHandler()
        }
    }
    func run(after: Int, completionHandler: @escaping () -> Void){
         let deadline = DispatchTime.now() + .seconds(after)
         DispatchQueue.main.asyncAfter(deadline: deadline) {
             completionHandler()
         }
     }
    
    func isUrlValid(spreadsheetURL: String?) {
        print("U DBB, ovo su following funcs: \(String(describing: spreadsheetURL))")
        if spreadsheetURL == spreadsheetURL {
            
            let parsedString = spreadsheetURL?.components(separatedBy: "/")
                        
            if parsedString?.contains("spreadsheets") == true {
            print("Parsed String in SB is: \(String(describing: parsedString))")
                isURLValid = true
            } else {
                isURLValid = false
                print("Not a valid URL entered! Enter a valid URL!")
                }
                } else {
            print("No Sheet URL detected!")
            }
    }
}
