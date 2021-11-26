//
//  Utils.swift
//  InventoryManager
//
//  Created by Milan Parađina on 25.03.2021..
//

import Foundation
import Toast_Swift
import UIKit

class Utils {
    
    let defaults = UserDefaults.standard
    var passedSheetName: String?
    
    func addToast(backgroundColor: UIColor, message: String, vc: UIViewController) {
        var style = ToastStyle()
            style.messageColor = .black
            style.backgroundColor = backgroundColor
            style.messageAlignment = .center
         vc.view.makeToast(message, duration: 2.0, position: .bottom, style: style)
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
    
    func addTwoActionAlert(title: String, message: String, actionTitle: String, vc: UIViewController, action: @escaping ((UIAlertAction) -> Void)) {
        let alert = UIAlertController(
                title: title,
                message: message,
                preferredStyle: UIAlertController.Style.alert
        )
        
        let action = UIAlertAction(title: actionTitle, style: .default, handler: action)
        let finish = UIAlertAction(title: K.popupStrings.alert.cancel, style: .cancel) { action in
            vc.dismiss(animated: true, completion: nil)
        }
        alert.addAction(action)
        alert.addAction(finish)
        vc.present(alert, animated: true, completion: nil)
    }
    
    func addTextFieldAlert(title: String, message: String, actionTitle: String, textField: UITextField ,textFieldHolder: String, vc: UIViewController, action: @escaping ((UIAlertAction) -> Void), fieldAction: @escaping ((UITextField) -> Void)) {
        let alert = UIAlertController(
                title: title,
                message: message,
                preferredStyle: UIAlertController.Style.alert
        )
        
        let action = UIAlertAction(title: actionTitle, style: .default, handler: action)
        let finish = UIAlertAction(title: K.popupStrings.alert.cancel, style: .cancel) { action in
            vc.dismiss(animated: true, completion: nil)
        }
        alert.addAction(action)
        alert.addAction(finish)
        alert.addTextField(configurationHandler: fieldAction)
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
    func run(after: Int, completionHandler: @escaping () -> Void){
         let deadline = DispatchTime.now() + .seconds(after)
         DispatchQueue.main.asyncAfter(deadline: deadline) {
             completionHandler()
         }
     }
    
    func isUrlValid(spreadsheetURL: String?, completionHandler: @escaping (Bool) -> Void) {
        if spreadsheetURL == spreadsheetURL {
            let parsedString = spreadsheetURL?.components(separatedBy: "/")
            if parsedString?.contains("spreadsheets") == true {
            print("Parsed String in SB is: \(String(describing: parsedString))")
                completionHandler(true)
            } else {
                completionHandler(false)
                print("Not a valid URL entered! Enter a valid URL!")
            }
        } else {
          return
        }
    }
    
    func getData(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
    }
    
    func downloadImage(from url: URL, completionHandler: @escaping (Data) -> Void){
        getData(from: url) { data, response, error in
            guard let data = data, error == nil else { return }
            print(response?.suggestedFilename ?? url.lastPathComponent)
            DispatchQueue.main.async() {
                completionHandler(data)
            }
        }
    }
    
    func imageWithImage(image: UIImage, scaledToSize newSize: CGSize) -> UIImage {
        UIGraphicsBeginImageContext(newSize)
        image.draw(in: CGRect(x: 0 ,y: 0 ,width: newSize.width ,height: newSize.height))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!.withRenderingMode(.alwaysOriginal)
    }
    
    func getCurrentDate() -> String {
        let formatter = DateFormatter()
            formatter.timeStyle = .short
            formatter.dateStyle = .long
        let currentDateTime = Date()
        let currentDate = formatter.string(from: currentDateTime)
        print("This is the current data: \(currentDate)")
        return currentDate
    }
}
