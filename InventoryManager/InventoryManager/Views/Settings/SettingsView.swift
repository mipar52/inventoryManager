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
    @State var presetAlert: Bool = false
    
    var body: some View {
        ZStack {
            LinearGradient(colors: [Color.purple.opacity(0.25), Color.blue.opacity(0.25)],
                           startPoint: .topLeading, endPoint: .bottomTrailing)
                .ignoresSafeArea()
            VStack {
                Text("ScanVentory Settings")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.leading)
                    .padding()
                ScrollView {
                    VStack(alignment: .leading, spacing: 5) {
                        Text("Signed in as: ")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                        
                        GoogleUserView(userImage: viewModel.userImage, userName: viewModel.username, isSignedIn: viewModel.isSignedIn)
                            .onTapGesture {
                                Task {
                                    do {
                                        if (viewModel.isSignedIn) {
                                            presetAlert.toggle()
                                        } else {
                                            try await viewModel.signIn()
                                        }
                                    } catch {
                                        viewModel.settingsError = error
                                        viewModel.showErrorAlert.toggle()
                                    }
                                }
                            }
                            .alert("Sign out", isPresented: $presetAlert, actions: {
                                
                                Button(role: .destructive) {
                                    Task {
                                        await viewModel.signOut()
                                    }
                                } label: {
                                    Text("Sign out")
                                }
                                
                                /// A cancellation button that appears with bold text.
                                Button("Cancel", role: .cancel) {
                                    // Perform cancellation
                                }
                            }, message: {
                                Text("Are you sure you want to sign out?")
                            })
                    }
                    .padding()
                    
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Application settings: ")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                        
                        NavigationLink {
                            SpreadsheetSettingsView(settingsVm: viewModel)
                        } label: {
                            FeatureCard(title: "Spreadsheets", subtitle: "Customize Spreadsheet & Sheet settings", systemImage: "document.badge.gearshape", isPressed: true)
                        }
                        
                        NavigationLink {
                            ScanSettingsView()
                            //   SpreadsheetSettingsView()
                        } label: {
                            FeatureCard(title: "Scan settings", subtitle: "Customize the scanning process", systemImage: "barcode.viewfinder", isPressed: true)
                        }
                        
                        NavigationLink {
                            QrCodeSettingsView()
                        } label: {
                            FeatureCard(title: "QR Code settings", subtitle: "Customize which formats of QR codes will the application accept", systemImage: "qrcode", isPressed: true)
                        }
                    }
                    .padding()
                    
                }
                
                Spacer()
            }
            .errorAlert(error: $viewModel.settingsError)
            //        VStack {
            //
            //            Button {
            //                Task {
            //                    do {
            //                        try await viewModel.syncGoogleSpreadsheets()
            //                    } catch {
            //                        debugPrint("Error: \(error.localizedDescription)")
            //                    }
            //                }
            //            } label: {
            //                Text("Sync Google Spreadsheets")
            //            }
            //            
            //            Button {
            //                Task {
            //                    do {
            //                        try  viewModel.deleteSpreadsheets()
            //                    } catch {
            //                        debugPrint("Error: \(error.localizedDescription)")
            //                    }
            //                }
            //            } label: {
            //                Text("Delete all Google Spreadsheets")
            //            }
            //        }
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
}

#Preview {
    SettingsView()
}
