//
//  AccountBrain.swift
//  InventoryManager
//
//  Created by Milan Parađina on 14.11.2021..
//

import Foundation
import GoogleSignIn
//import GTMSessionFetcher
import GoogleAPIClientForREST

class SignInBrain {
    
    let sheetService = GTLRSheetsService()
    let driveService = GTLRDriveService()
    
    let defaults = UserDefaults.standard
    var currentUser = "user"
    
    func googleSignIn(vc: UIViewController, completionHandler: @escaping (Bool, GIDGoogleUser?) -> Void) {
           GIDSignIn.sharedInstance.restorePreviousSignIn { user, error in
               if error == nil {
                   print("Managed to restore previous sign in!\nScopes: \(String(describing: user?.grantedScopes))")
                   self.requestScopes(vc: vc, googleUser: user!) { success in
                       if success == true {
                           completionHandler(true, user)
                       } else {
                           completionHandler(false, user)
                       }
                   }
               } else {
                   print("No previous user!\nThis is the error: \(String(describing: error?.localizedDescription))")
                   let signInConfig = GIDConfiguration.init(clientID: K.keys.clientID)
                   GIDSignIn.sharedInstance.signIn(with: signInConfig, presenting: vc) { gUser, signInError in
                       if signInError == nil {
                           self.requestScopes(vc: vc, googleUser: gUser!) { signInSuccess in
                               if signInSuccess == true {
                                   completionHandler(true, gUser)
                                   //askForDriveSheeet -> here
                               } else {
                                   completionHandler(false, gUser)
                               }
                           }
                       } else {
                           print("error with signing in: \(String(describing: signInError)) ")
                         self.sheetService.authorizer = nil
                         self.driveService.authorizer = nil
                           completionHandler(false, user)
                       }
                   }
               }
           }
       }
       
    func requestScopes(vc: UIViewController, googleUser: GIDGoogleUser, completionHandler: @escaping (Bool) -> Void) {
           let grantedScopes = googleUser.grantedScopes
        if grantedScopes == nil || !grantedScopes!.contains(K.scopes.grantedScopes) {
            let additionalScopes = K.scopes.additionalScopes
               
               GIDSignIn.sharedInstance.addScopes(additionalScopes, presenting: vc) { user, scopeError in
                   if scopeError == nil {
                       user?.authentication.do { authentication, err in
                           if err == nil {
                               guard let authentication = authentication else { return }
                               // Get the access token to attach it to a REST or gRPC request.
                              // let accessToken = authentication.accessToken
                               let authorizer = authentication.fetcherAuthorizer()
                               self.sheetService.authorizer = authorizer
                               self.driveService.authorizer = authorizer
                               completionHandler(true)
                           } else {
                               print("Error with auth: \(String(describing: err?.localizedDescription))")
                               completionHandler(false)
                           }
                       }
                   } else {
                       completionHandler(false)
                       print("Error with adding scopes: \(String(describing: scopeError?.localizedDescription))")
                   }
               }
           } else {
               print("Already contains the scopes!")
               completionHandler(true)
           }
       }
   }

