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
    
    private var googleDriveService: GoogleDriveService?
    
    func configureViewModel(with db: DatabaseService) async throws {
        googleDriveService = GoogleDriveService(db: db)
        try await googleDriveService?.configure()
    }
    
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
        let _ = try await GoogleAuthManager.shared.signIn()
        await syncFromGoogleAuthManager()
    }
    
    func signOut() async {
        await GoogleAuthManager.shared.singOut()
        self.username = "Not signed in"
        self.userImage = nil
        self.isSignedIn = false
    }
    
    func syncGoogleSpreadsheets() async throws {
        try await googleDriveService?.retriveSpreadsheetsFromDrive()
    }
}
