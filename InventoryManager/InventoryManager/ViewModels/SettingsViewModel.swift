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
    
    @Published var isLoading: Bool = false
    @Published var currentSheet: String = ""
    
    @Published var showErrorAlert: Bool = false
    @Published var settingsError: Error?
    
    private var googleDriveService: GoogleDriveService?
    private var dbService: DatabaseService?
    
    func configureViewModel(with db: DatabaseService) async throws {
        dbService = db
        googleDriveService = GoogleDriveService(db: db)
        try await googleDriveService?.configure()
    }
    
    func performTaskWithLoading(loadingMessage: String = "Initilizing the process..\nHang tight!", _ asyncWork: () async throws -> Void) async {
        currentSheet = loadingMessage
        isLoading = true
        defer { isLoading = false; currentSheet = "Loading…" }

        do {
            try await asyncWork()
        } catch {
            showErrorAlert.toggle()
            settingsError = error
            debugPrint(error.localizedDescription)
        }
        
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
            self.username = "Not signed in.\nTap to sign in"
            self.userImage = nil
            self.isSignedIn = false
            showErrorAlert.toggle()
            settingsError = error
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
        try await googleDriveService?.retriveSpreadsheetsFromDrive { [weak self] progressSheet in
                self?.currentSheet = "Almost there!\nCurrently checking Spreadsheet:\n\(progressSheet)"
        }
    }
    
    func deleteSpreadsheets() throws {
        try dbService?.deleteAllSpreadsheets()
    }
}
