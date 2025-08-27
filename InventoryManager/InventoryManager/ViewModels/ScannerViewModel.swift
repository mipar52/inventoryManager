//
//  ScannerViewModel.swift
//  InventoryManager
//
//  Created by Milan Parađina on 03.08.2025..
//

import UIKit
import AVFoundation
import Combine

// mock -> za testiranje npr. MocScannerVM: ScannerViewModelProtocol
protocol ScannerViewModelProtocol {
    func bindService()
    
}

class ScannerVM: ScannerViewModelProtocol {
    func bindService() {
        
    }
}

class ScannerViewModel: NSObject, ObservableObject {
    @Published var qrCodeResult: QRCodeResult?
    @Published var qrCodeScannerService: QRScannerService
    @Published var flashlightPressed: Bool = false
    //    @Published var qrCodeResult: String? = nil {
    //        didSet {
    //            isSuccess = qrCodeResult != nil
    //        }
    //    }
    
    @Published var isSuccess: Bool = false
    @Published var selectedSpreadsheet: Spreadsheet?
    @Published var selectedSheet: Sheet?
    @Published var spreadsheets: [GoogleSpreadsheet]?
    @Published var presentError: Bool = false
    @Published var errorMessage: String = ""
    @Published var presentQrError: Bool = false
    
    private var spreadsheetsService: GoogleSpreadsheetService
    private(set) var dbService: DatabaseService?
    
    private let qrCodeSettingsService: QrCodeSettingsStoreService
    private let scanSettingsService: ScanSettingsStoreService
    
    @Published var shouldPresentQrCodeResult: Bool = false
    var isSucess: Bool { qrCodeResult != nil }
    var shouldSaveDataOnDismiss: Bool {
        scanSettingsService.saveDataOnDismiss ?? true
    }
    var shouldSaveDataOnError: Bool {
        scanSettingsService.saveDataOnError ?? true
    }
    private var cancellables = Set<AnyCancellable>() // -> don't need it as assing is being used now
    
    init(
        qrCodeScannerService: QRScannerService = QRScannerService(),
        googleSpreadsheetsService: GoogleSpreadsheetService = GoogleSpreadsheetService(),
        qrcodeSettingService: QrCodeSettingsStoreService = QrCodeSettingsStoreService(),
        scanSettingsSerive: ScanSettingsStoreService = ScanSettingsStoreService()
    ) {
        self.qrCodeScannerService = qrCodeScannerService
        self.spreadsheetsService = googleSpreadsheetsService
        self.qrCodeSettingsService = qrcodeSettingService
        self.scanSettingsService = scanSettingsSerive
        super.init()
        self.bindService()
        Task {
            do {
                try await spreadsheetsService.configure()
            } catch {
                presentError.toggle()
                debugPrint(error.localizedDescription)
            }
        }
    }
    
    private func bindService() {
        
        qrCodeScannerService.$scannedCode
            .receive(on: DispatchQueue.main)
            .sink { [weak self] qr in
                guard let self = self else {return}
                if let qr {
                    debugPrint("[ScannerViewModel] - found QR code: \(qr)")
                    var qrCodeResult: [String] = [qr]
                    if let delimiter = qrCodeSettingsService.qrCodeDelimiter {
                        qrCodeResult = qr.components(separatedBy: delimiter)
                    }
                    if let qrAcceptanceText = qrCodeSettingsService.qrAcceptanceText {
                        if !(qrCodeResult.contains(qrAcceptanceText)) {
                            errorMessage = "Invalid QR code!\nQR code does not contain \(qrAcceptanceText)"
                            presentQrError.toggle()
                            return
                        }
                        if let ignoreQrAcceptanceText = qrCodeSettingsService.ignoreQrAcceptanceText,
                           let index = qrCodeResult.firstIndex(of: qrAcceptanceText) {
                            if ignoreQrAcceptanceText {
                                qrCodeResult.remove(at: index)
                            }
                        }
                    }
                    
                    self.qrCodeResult = QRCodeResult(value: qrCodeResult)

                    if let shouldPreset = scanSettingsService.showQrResultScreen,
                       shouldPreset == true {
                        shouldPresentQrCodeResult.toggle()
                    } else {
                        Task {
                            await self.appendToSpreadsheet()
                            self.isSuccess.toggle()
                        }
                        
                    }
                } else {
                    self.qrCodeResult = nil
                }
            }
            .store(in: &cancellables)
        
        //        driveService.$spreadsheets
        //            .receive(on: DispatchQueue.main)
        //            .sink { [weak self] spredsheets in
        //                self?.spreadsheets = spredsheets
        //                self?.selectedSpreadsheet = spredsheets.first
        //                self?.selectedSheet = self?.selectedSpreadsheet?.sheets.first
        //            }
        //            .store(in: &cancellables)
        
        //        qrCodeScannerService.$scannedCode
        //            .receive(on: DispatchQueue.main)
        //            .assign(to: &$qrCodeResult)
        
    }
    
    func configureGoogleService(_ dbService: DatabaseService) async throws {
        try await self.spreadsheetsService.configure()
        self.dbService = dbService
    }
    
    func appendToSpreadsheet() async {
        do {
            if let result = qrCodeResult {
                try await self.spreadsheetsService.appendDataToSheet(
                    qrCodeData: result.value,
                    qrDelimiter: qrCodeSettingsService.qrCodeDelimiter,
                    qrCodeWord: qrCodeSettingsService.qrAcceptanceText)
            }
        } catch {
            if error is QrError {
                presentQrError.toggle()
                errorMessage = error.localizedDescription
            } else {
                debugPrint(error.localizedDescription)
                presentError.toggle()
            }
        }
    }
    
    @MainActor
    func saveQrCodeData() {
        if let result = qrCodeResult {
            dbService?.creatQrCodeData(with: result.value.joined(separator: qrCodeSettingsService.qrCodeDelimiter ?? ""), timestamp: Date())
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
