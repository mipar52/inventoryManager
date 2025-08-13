//
//  SettingsView.swift
//  InventoryManager
//
//  Created by Milan Parađina on 01.08.2025..
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var db: DatabaseService
    @StateObject var viewModel = SettingsViewModel()
    
    var body: some View {
        VStack {
            GoogleUserView(userImage: viewModel.userImage, userName: viewModel.username, isSignedIn: viewModel.isSignedIn)
                .onTapGesture {
                    Task {
                        do {
                            if (viewModel.isSignedIn) {
                               await viewModel.signOut()
                            } else {
                                try await viewModel.signIn()
                            }
                        } catch {
                            
                        }
                    }
                }
            Button {
                Task {
                    do {
                        try await viewModel.syncGoogleSpreadsheets()
                    } catch {
                        debugPrint("Error: \(error.localizedDescription)")
                    }
                }
            } label: {
                Text("Sync Google Spreadsheets")
            }
            
            Button {
                Task {
                    do {
                        try  viewModel.deleteSpreadsheets()
                    } catch {
                        debugPrint("Error: \(error.localizedDescription)")
                    }
                }
            } label: {
                Text("Delete all Google Spreadsheets")
            }
        }
        .onAppear {
            Task {
                do {
                    try await viewModel.configureViewModel(with: db)
                    await viewModel.syncFromGoogleAuthManager()
                } catch {
                    debugPrint("[SettingsVM] - error: \(error.localizedDescription)")
                }
            }

            }
        }
}

#Preview {
    SettingsView()
}
