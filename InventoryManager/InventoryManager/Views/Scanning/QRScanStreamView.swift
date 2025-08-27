import SwiftUI

struct QRScanStreamView: View {
    // private var
    // @ObservedObject private var scannerViewModel: ScannerViewModel
    //
    @ObservedObject var scannerViewModel: ScannerViewModel
    @ObservedObject var spreadsheetPickerViewModel: SpreadsheetPickerViewModel

    @State private var showFlashToast: Bool = false
    @State private var showReticleTips: Bool = true
    @State private var onDismissQrResultScreen = false
    @State private var presentErrorToast: Bool = false
    //@ObservedObject private var scanSettingsVm: ScanSettingsViewModel
    
//    init(scannerViewModel: ScannerViewModel, spreadsheetPickerViewModel: SpreadsheetPickerViewModel, showFlashToast: Bool = false, showReticleTips: Bool = true, scanSettingsVm: ScanSettingsViewModel) {
//        self.scannerViewModel = scannerViewModel
//        self.spreadsheetPickerViewModel = spreadsheetPickerViewModel
//        self.showFlashToast = showFlashToast
//        self.showReticleTips = showReticleTips
//        self.scanSettingsVm = scanSettingsVm
//    }
    
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
                        if scannerViewModel.flashlightPressed {
                            showFlashToast = true
                        }
                    } label: {
                        Image(systemName: scannerViewModel.flashlightPressed
                              ? "flashlight.on.fill" : "flashlight.off.fill")
                            .font(.system(size: 22, weight: .semibold))
                            .padding(12)
                            .background(.ultraThinMaterial, in: Circle())
                    }
                    .accessibilityLabel(scannerViewModel.flashlightPressed ? "Turn flashlight off" : "Turn flashlight on")
                    .padding(.trailing, 8)
                }
                .padding(.horizontal)
                .padding(.top, 14)

                Spacer()
                if scannerViewModel.isSuccess {
                    ToastView(labelText: "Data sent!")
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                        .padding(.bottom, 24)
                        .task {
                            try? await Task.sleep(nanoseconds: 2_000_000_000)
                            withAnimation(.easeOut) { showFlashToast = false }
                        }
                }
                if scannerViewModel.presentError {
                    ToastView(labelText:
                                scannerViewModel.shouldSaveDataOnError ?
                              "Could not send data to sheet! Saving it instead.." : "Could not send data to sheet!")
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                        .padding(.bottom, 24)
                        .task {
                            try? await Task.sleep(nanoseconds: 2_000_000_000)
                            withAnimation(.easeOut) { scannerViewModel.presentError = false }
                            scannerViewModel.startScanningSession()
                        }
                }
                if showFlashToast {
                    ToastView(labelText: "Watch out for glare!")
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                        .padding(.bottom, 24)
                        .task {
                            try? await Task.sleep(nanoseconds: 2_000_000_000)
                            withAnimation(.easeOut) { showFlashToast = false }
                        }
                }
                
                if onDismissQrResultScreen {
                    ToastView(labelText: "Saving the data to device...")
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                        .padding(.bottom, 24)
                        .task {
                            try? await Task.sleep(nanoseconds: 2_000_000_000)
                            withAnimation(.easeOut) { onDismissQrResultScreen = false }
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
        .sheet(isPresented: $scannerViewModel.shouldPresentQrCodeResult, onDismiss: {
            if scannerViewModel.shouldSaveDataOnDismiss && !scannerViewModel.presentError  {
                scannerViewModel.saveQrCodeData()
                onDismissQrResultScreen.toggle()
            }
            Task { @MainActor in
                try? await Task.sleep(nanoseconds: 800_000_000)
                scannerViewModel.qrCodeResult = nil
                scannerViewModel.startScanningSession()
                
            }
        }) {
            QRCodeResultScreen(viewModel: scannerViewModel)
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)
                .padding()
        }
        .alert(Text("QR code error"), isPresented: $scannerViewModel.presentQrError) {
            Button(role: .cancel) {
                scannerViewModel.startScanningSession()
            } label: {
                Text("OK")
            }

        } message: {
            Text(scannerViewModel.errorMessage)
        }
    }
}
