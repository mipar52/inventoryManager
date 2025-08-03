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
    @Published var selectedSpreadsheet: GoogleSpreadsheet?
    @Published var selectedSheet: GoogleSheet?
    @Published var spreadsheets: [GoogleSpreadsheet]?
    
    private var spreadsheetsService: GoogleSpreadsheetService
    @Published private var driveService: GoogleDriveService
    private var cancellables = Set<AnyCancellable>() // -> don't need it as assing is being used now
    
    init(
        qrCodeScannerService: QRScannerService = QRScannerService(),
        googleSpreadsheetsService: GoogleSpreadsheetService = GoogleSpreadsheetService(),
        googleDriveService: GoogleDriveService = GoogleDriveService()
    ) {
        self.qrCodeScannerService = qrCodeScannerService
        self.spreadsheetsService = googleSpreadsheetsService
        self.driveService = googleDriveService
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
        
        driveService.$spreadsheets
            .receive(on: DispatchQueue.main)
            .sink { [weak self] spredsheets in
                self?.spreadsheets = spredsheets
                self?.selectedSpreadsheet = spredsheets.first
                self?.selectedSheet = self?.selectedSpreadsheet?.sheets.first
            }
            .store(in: &cancellables)
        
//        qrCodeScannerService.$scannedCode
//            .receive(on: DispatchQueue.main)
//            .assign(to: &$qrCodeResult)
        
    }
    
    func configureGoogleService() async throws {
        try await self.spreadsheetsService.configure()
    }
    
    func configureGoogleDrive() async throws {
        try await self.driveService.configure()
    }
    
    func getSpreadsheets() async throws {
        try await self.driveService.retriveSpreadsheetsFromDrive()
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
