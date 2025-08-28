import SwiftUI

struct QRScanStreamView: View {
    // private var
    // @ObservedObject private var scannerViewModel: ScannerViewModel
    //
    @ObservedObject private var scannerViewModel: ScannerViewModel
    @ObservedObject private var spreadsheetPickerViewModel: SpreadsheetPickerViewModel

    @State private var showFlashToast: Bool = false
    
    init(scannerViewModel: ScannerViewModel, spreadsheetPickerViewModel: SpreadsheetPickerViewModel) {
        self.scannerViewModel = scannerViewModel
        self.spreadsheetPickerViewModel = spreadsheetPickerViewModel
    }

    var body: some View {
        ZStack {
            ScannerView(scannerViewModel: scannerViewModel)
                .ignoresSafeArea()
            
            QRRecticleOverlay()

            VStack {
                HStack(spacing: 12) {
                    SpreadsheetPicker(viewModel: spreadsheetPickerViewModel)
                        .accessibilityLabel("Destination spreadsheet and sheet")

                    Spacer()

                    Button {
                        scannerViewModel.toggleFlashlight()
                        if scannerViewModel.isFlashlightOn {
                            showFlashToast = true
                        }
                    } label: {
                        Image(systemName: scannerViewModel.isFlashlightOn
                              ? "flashlight.on.fill" : "flashlight.off.fill")
                            .font(.system(size: 22, weight: .semibold))
                            .padding(12)
                            .background(.ultraThinMaterial, in: Circle())
                    }
                    .accessibilityLabel(scannerViewModel.isFlashlightOn ? "Turn flashlight off" : "Turn flashlight on")
                    .padding(.trailing, 8)
                }
                .padding(.horizontal)
                .padding(.top, 14)

                Spacer()
                if showFlashToast {
                    ToastView(labelText: "Watch out for glare!")
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                        .padding(.bottom, 24)
                        .task {
                            try? await Task.sleep(nanoseconds: 2_000_000_000)
                            withAnimation(.easeOut) { showFlashToast.toggle() }
                        }
                }
                
                if scannerViewModel.success {
                    ToastView(labelText: "Data sent!")
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                        .background(Color.green)
                        .padding(.bottom, 24)
                        .task {
                            try? await Task.sleep(nanoseconds: 2_000_000_000)
                            withAnimation(.easeOut) { scannerViewModel.success.toggle() }
                        }
                }
            }
        }
        .navigationTitle("Live Scan")
        .navigationBarTitleDisplayMode(.inline)
        
        .onAppear {
            scannerViewModel.startScanningSession()
        }
        .onDisappear {
            scannerViewModel.stopScanningSession()
        }
        .sheet(item: $scannerViewModel.qrCodeResult, onDismiss: {
            scannerViewModel.onSheetDismiss()
        }, content: { _ in
            QRCodeResultScreen(viewModel: scannerViewModel)
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)
                .padding()
        })
        .alert(item: $scannerViewModel.uiError) { err in
            Alert(title: Text("Error"),
                  message: Text(err.localizedDesction),
                  dismissButton: .default(Text("OK"), action: {
                scannerViewModel.startScanningSession()
            })
            )
            
        }
    }
}
