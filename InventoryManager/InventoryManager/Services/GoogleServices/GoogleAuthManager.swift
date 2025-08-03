//
//  GoogleAuthManager.swift
//  InventoryManager
//
//  Created by Milan Parađina on 02.08.2025..
//

import Foundation
import GoogleSignIn
import GoogleAPIClientForREST_Sheets

actor GoogleAuthManager {
    static let shared = GoogleAuthManager()
    
    private(set) var googleUser: GIDGoogleUser?
    private(set) var sheetsService: GTLRSheetsService?
    
    func restoreSession() async throws {
        self.googleUser = try await GIDSignIn.sharedInstance.restorePreviousSignIn()
        self.sheetsService?.authorizer = googleUser?.fetcherAuthorizer
  
        // old way with callbacks
//        await withCheckedContinuation { continuation in
//            GIDSignIn.sharedInstance.restorePreviousSignIn() { user, error in
//                self.googleUser = user
//                if let user = user {
//                    self.sheetsService?.authorizer = user.fetcherAuthorizer
//                }
//                continuation.resume()
//            }
//        }
    }
    
    func handleUrl(_ url: URL) {
        GIDSignIn.sharedInstance.handle(url)
    }
    
    func restoreTokenIfNeeded<T: GTLRService>(_ type: T.Type) async throws -> T {
        guard let user = googleUser else { throw GoogleAuthError.NotSignedIn }
        let accessToken = user.accessToken.tokenString
        let authorizer = try await user.refreshTokensIfNeeded()

        let service = T()
        service.additionalHTTPHeaders = ["Authorization": "Bearer \(accessToken)"]
        service.authorizer = authorizer.fetcherAuthorizer
        
        return service
    }
    
    func signIn() async throws -> GIDSignInResult {
        guard let rootVc = await ViewUtilities.getTopViewController() else {
            debugPrint("[GoogleSignInError] - could not get top view controller")
            throw GoogleAuthError.SignInError(error: "[GoogleSignInError] - could not get top view controller")
        }
        return try await withCheckedThrowingContinuation { continuation in
            GIDSignIn.sharedInstance.signIn(
                withPresenting: rootVc,
                hint: nil,
                additionalScopes: GoogleConstans.googleScopes) { signInResult, signInError in
                    if signInError == nil {
                        if let result = signInResult {
                            continuation.resume(returning: result)
                        }
                    } else {
                        continuation.resume(throwing: GoogleAuthError.SignInError(error: signInError?.localizedDescription))
                        debugPrint("[GoogleSignInError] - Error with sign in: \(signInError?.localizedDescription ?? "No error description")")
                    }
                }
        }

    }
    
    func singOut() {
        GIDSignIn.sharedInstance.signOut()
    }
    
    func getUserProfile() async throws -> (String?, URL?)? {
        guard let user = self.googleUser else {
            print("[GoogleAuthManager] No signed-in user")
            return nil
        }

        print("[GoogleAuthManager] Returning user: \(user.profile?.name ?? "Unknown")")
        return (user.profile?.name, user.profile?.imageURL(withDimension: 100))
    }

}
