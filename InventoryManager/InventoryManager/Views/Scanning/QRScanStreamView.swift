import SwiftUI

struct QRScanStreamView: View {
    @ObservedObject var scannerViewModel: ScannerViewModel
    @ObservedObject var spreadsheetPickerViewModel: SpreadsheetPickerViewModel

    @State private var showFlashToast = false
    @State private var showReticleTips = true
    
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

                if showFlashToast {
                    ToastView(labelText: "Watch out for glare!")
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                        .padding(.bottom, 24)
                        .task {
                            try? await Task.sleep(nanoseconds: 2_000_000_000)
                            withAnimation(.easeOut) { showFlashToast = false }
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
        .sheet(isPresented: $scannerViewModel.showQrCodeResult, onDismiss: {
            scannerViewModel.qrCodeResult = nil
            Task { @MainActor in
                try? await Task.sleep(nanoseconds: 800_000_000)
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
