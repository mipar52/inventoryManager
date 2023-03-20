//
//  MainScreenController.swift
//  InventoryManager
//
//  Created by Milan Parađina on 25.03.2021..
//

import UIKit

class MainScreenController: UIViewController {
    
    let accountBrain = SignInBrain()
    let utils = Utils()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        accountBrain.googleSignIn(vc: self) { success, user  in
            if success == true {
                self.utils.addToast(backgroundColor: K.colors.success, message: K.accountStrings.signInString , vc: self)
            } else {
                self.utils.addToast(backgroundColor: K.colors.error, message: K.accountStrings.signInIssues, vc: self)
            }
        }
    }
    
    @IBAction func scanPressed(_ sender: UIButton) {
        performSegue(withIdentifier: "goToCamera", sender: self)
    }
}
