//
//  SettingsView.swift
//  InventoryManager
//
//  Created by Milan Parađina on 01.08.2025..
//

import SwiftUI

struct SettingsView: View {
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
        }
        .onAppear {
            Task {
                await viewModel.syncFromGoogleAuthManager()
            }
        }

    }
}

#Preview {
    SettingsView()
}
