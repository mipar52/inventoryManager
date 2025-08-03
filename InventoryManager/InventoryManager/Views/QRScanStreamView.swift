//
//  QRScanStreamView.swift
//  InventoryManager
//
//  Created by Milan Parađina on 02.08.2025..
//

import SwiftUI

struct QRScanStreamView: View {
    @StateObject var scannerViewModel: ScannerViewModel
    @State var showFlashToast = false
    @State var showQrResultScreen = false
    
    var body: some View {
        ZStack {
            ScannerView(scannerViewModel: scannerViewModel)

            VStack {
                HStack {
                    SpreadsheetPicker(viewModel: scannerViewModel)
                    Spacer()
                    Button {
                        scannerViewModel.toggleFlashlight()
                        if scannerViewModel.flashlightPressed {
                            showFlashToast.toggle()
                        }
                    } label: {
                        
                        Image(systemName: scannerViewModel.flashlightPressed ? "flashlight.off.circle.fill" : "flashlight.slash.circle")
                            .font(.largeTitle)
                            .padding()
                            .background(.ultraThinMaterial)
                            .clipShape(Circle())
                    }

                    .padding()
                    .padding(.top, 30)
                }

                Spacer()
                if showFlashToast {
                    ToastView(labelText: "Watch out for glare!")
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                showFlashToast.toggle()
                            }
                        }
                        .transition(.move(edge: .top).combined(with: .opacity))
                        .animation(.easeOut(duration: 0.3), value: showFlashToast)
                        
                }
//                if let code = scannerViewModel.qrCodeResult {
//                    ToastView(labelText: code)
//                        .hoverEffect()
//                }
            }
        }
      //  .ignoresSafeArea()
        .onAppear {
            scannerViewModel.startScanningSession()
            Task {
                do {
                    try await scannerViewModel.configureGoogleDrive()
                    try await scannerViewModel.getSpreadsheets()
                } catch {
                    debugPrint("[GoogleDriveService] - \(error.localizedDescription)")
                }
            }
        }
        .onDisappear { scannerViewModel.stopScanningSession() }
        .sheet(isPresented: $scannerViewModel.showQrCodeResult, onDismiss: {
            scannerViewModel.qrCodeResult = nil
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                scannerViewModel.startScanningSession()
            }
        }) {
            QRCodeResultScreen(viewModel: scannerViewModel)
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)
                .padding()
        }
        }
    }


#Preview {
    QRScanStreamView(scannerViewModel: ScannerViewModel())
}
