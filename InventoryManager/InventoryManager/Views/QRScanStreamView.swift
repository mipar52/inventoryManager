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
    
    var body: some View {
        ZStack {
            ScannerView(scannerViewModel: scannerViewModel)

            VStack {
                HStack {
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
                if let code = scannerViewModel.qrCodeResult {
                    ToastView(labelText: code)
                        .hoverEffect()
                }
            }
        }
      //  .ignoresSafeArea()
        .onAppear { scannerViewModel.startScanningSession() }
        .onDisappear { scannerViewModel.stopScanningSession() }
        }
    }


#Preview {
    QRScanStreamView(scannerViewModel: ScannerViewModel())
}
