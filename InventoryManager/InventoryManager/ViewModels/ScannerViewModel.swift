//
//  ScannerViewModel.swift
//  InventoryManager
//
//  Created by Milan Parađina on 03.08.2025..
//

import UIKit
import AVFoundation
import Combine

class ScannerViewModel: NSObject, ObservableObject {
    @Published var qrCodeScannerService: QRScannerService
    @Published var flashlightPressed: Bool = false
    @Published var qrCodeResult: String? = nil {
        didSet {
            showQrCodeResult = qrCodeResult != nil
        }
    }
    @Published var showQrCodeResult: Bool = false
    
    private var spreadsheetsService: GoogleSpreadsheetService
    private var cancellables = Set<AnyCancellable>() // -> don't need it as assing is being used now
    
    init(
        qrCodeScannerService: QRScannerService = QRScannerService(),
        googleSpreadsheetsService: GoogleSpreadsheetService = GoogleSpreadsheetService()
    ) {
        self.qrCodeScannerService = qrCodeScannerService
        self.spreadsheetsService = googleSpreadsheetsService
        super.init()
        self.bindService()
    }
    
    private func bindService() {
        
            qrCodeScannerService.$scannedCode
                .receive(on: DispatchQueue.main)
                .sink { [weak self] qr in
                    self?.qrCodeResult = qr
                    self?.showQrCodeResult = qr != nil
                }
                .store(in: &cancellables)
        
//        qrCodeScannerService.$scannedCode
//            .receive(on: DispatchQueue.main)
//            .assign(to: &$qrCodeResult)
        
    }
    
    func configureGoogleService() async throws {
        try await self.spreadsheetsService.configure()
    }
    
    func appendToSpreadsheet() async throws {
        if let result = qrCodeResult {
            try await self.spreadsheetsService.appendDataToSheet(qrCodeData: result)
        }
    }
    
    func getPreviewLayer() -> AVCaptureVideoPreviewLayer {
        qrCodeScannerService.getPreviewLayer()
    }
    
    func startScanningSession() {
        qrCodeScannerService.startSession()
    }
    
    func stopScanningSession() {
        qrCodeScannerService.stopSession()
    }
    
    func toggleFlashlight() {
        flashlightPressed.toggle()
        qrCodeScannerService.toggleFlashlight(status: flashlightPressed)
    }
    
    func decodeQrCode(from image: UIImage) {
        qrCodeScannerService.decodeQRCodeFromStaticImage(from: image)
    }
}
