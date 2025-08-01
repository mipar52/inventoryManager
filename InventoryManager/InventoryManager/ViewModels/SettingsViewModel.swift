//
//  SettingsViewModel.swift
//  InventoryManager
//
//  Created by Milan Parađina on 01.08.2025..
//

import Foundation
import SwiftUI
import GoogleSignIn

@MainActor
class SettingsViewModel: ObservableObject {
    @Published var isSignedIn: Bool = false
    @Published var username: String = ""
    @Published var userImage: UIImage? = nil
    
    func syncFromGoogleAuthManager () async {
        do {
            let googleAuthManager = GoogleAuthManager.shared
            if let (googleUsername, googleUserImage) = try await googleAuthManager.getUserProfile() {
                isSignedIn = true
                if let googleUsername = googleUsername {
                    username = googleUsername
                }
                if let googleUserImage = googleUserImage {
                    Task {
                        let (data,_) = try await URLSession.shared.data(from: googleUserImage)
                        userImage = UIImage(data: data)
                    }
                }
            }
        } catch {
            debugPrint("[GoogleAuthManager] - Error: \(error)")
            self.username = "Not signed in"
            self.userImage = nil
            self.isSignedIn = false
        }
    }
    
    func signIn() async throws {
        let result = try await GoogleAuthManager.shared.signIn()
        await syncFromGoogleAuthManager()
    }
    
    func signOut() async {
        await GoogleAuthManager.shared.singOut()
        self.username = "Not signed in"
        self.userImage = nil
        self.isSignedIn = false
    }
}
