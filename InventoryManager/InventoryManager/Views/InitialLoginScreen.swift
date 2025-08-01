//
//  InitialLoginScreen.swift
//  InventoryManager
//
//  Created by Milan Parađina on 01.08.2025..
//

import SwiftUI
import GoogleSignInSwift

struct InitialLoginScreen: View {
    @StateObject private var viewModel = InitialLoginViewModel()
    @State private var isLoading: Bool = false
    var body: some View {
        NavigationStack {
            ZStack {
                Color.purpleColor.ignoresSafeArea()
                
                VStack(spacing: 15) {
                    
                    Spacer().frame(height:60)
                    
                    Text("Welcome to ScanVentory!")
                        .font(.largeTitle)
                        .fontWeight(.semibold)
                        .foregroundStyle(.white)
                        .padding(.bottom)
                        .padding(.horizontal, 5)
                    
                    Text("First time using ScanVentory?")
                        .font(.title)
                        .foregroundColor(.white)
                        .padding(.horizontal, 24)
                    
                    Spacer().frame(height:40)
                    
                    VStack(spacing: 20) {
                        
                        Text("To get the full expirience please login using your Google account. Your Google information is needed here only to send the information from the scanned objects to your selected Spreadsheets.")
                        
                        Text("No worries, if you do not want to login right now, you can proceed to using the application by pressing the 'Skip' button above.")
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding(.horizontal, 24)
                    .multilineTextAlignment(.leading)
                    
                    Spacer().frame(height: 24)
                    
                    HStack {
                        Spacer()
                        GoogleSignInButton {
                            isLoading.toggle()
                            defer { isLoading.toggle() }
                            Task {
                                do {
                                    try await viewModel.performLogin()
                                } catch {
                                    
                                }
                            }
                        }
                        .frame(width: 100, height: 50)
                        Spacer()
                    }
                    
                    Button {
                        viewModel.finishedOnboarding()
                    } label: {
                        SimpleHorizontalView(labelText: "Skip", uiImageText: "arrow.right.circle")
                            .padding(.horizontal, 24)
                    }
                    Spacer().frame(height: 40)
                }
                .withLoadingOverlay($isLoading)
                .navigationDestination(isPresented: $viewModel.shouldNavigateToMainView) {
                    MainView()
                }
                .background {
                    Color.purpleColor
                }
                .frame(
                    minWidth: 0,
                    maxWidth: .infinity,
                    minHeight: 0,
                    maxHeight: .infinity,
                    alignment: .topLeading
                )
                .ignoresSafeArea()
            }
        }
    }
}

#Preview {
    InitialLoginScreen()
}
