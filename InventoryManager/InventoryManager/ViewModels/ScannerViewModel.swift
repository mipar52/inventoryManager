//
//  ScannerViewModel.swift
//  InventoryManager
//
//  Created by Milan Parađina on 03.08.2025..
//

import UIKit
import AVFoundation
import Combine

@MainActor
final class ScannerViewModel: NSObject, ObservableObject {
        
    @Published var qrCodeResult: QRCodeResult?
    @Published var isFlashlightOn = false
    @Published var uiError: UIScanningError?
    
    var shouldShowResultSheet: Bool {
        qrCodeResult != nil && scanningSettings.showQrCodeScreen
    }
    
    // dependencies
    private let scanner: QRScanning
    private let sheets: GoogleSpreadsheetWriter
    private let selection: SelectionProvider
    private let qrSettings: QrSettingsProvider
    private let scanningSettings: ScanSettingProvider
    private let db: DatabaseProvider

    private var cancellables = Set<AnyCancellable>() // -> don't need it as assing is being used now
    
    init(scanner: QRScanning,
         sheets: GoogleSpreadsheetWriter,
         selection: SelectionProvider,
         qrSettings: QrSettingsProvider,
         scanningSettings: ScanSettingProvider,
         db: DatabaseProvider
         ) {
        self.scanner = scanner
        self.sheets = sheets
        self.selection = selection
        self.qrSettings = qrSettings
        self.scanningSettings = scanningSettings
        self.db = db
        
        bindScanner()
        Task { try? await sheets.configure() }
    }
    
    private func bindScanner() {
        scanner.scannedQrCodePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] rawQr in
                guard let self = self else { return }
                guard let rawQr, !rawQr.isEmpty else {
                    self.qrCodeResult = nil
                    return
                }
                
                let qrCodeSettings = QRCodeSettings(delimiter: qrSettings.qrCodeDelimiter,
                                                    acceptanceText: qrSettings.qrAcceptanteText,
                                                    ignoreAcceptanceText: qrSettings.ignoreQrAcceptanceText)
                
                //  parse
                
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
    
    private func parse(rawQr: String, using settings: QRCodeSettings) -> Result<[String], UIScanningError> {
        
        var parts: [String] = {
            guard let delimiter = settings.delimiter, !delimiter.isEmpty else { return [rawQr] }
        }()
        
        if let required = settings.acceptanceText, !required.isEmpty {
            guard let index = parts.firstIndex(of: required) else {
                return .failure(UIScanningError.invalidQrCode(missing: required))
            }
            if settings.ignoreAcceptanceText {
                parts.remove(at: index)
            }
        }
        
        return .success(parts)
    }
    
    func getPreviewLayer() -> AVCaptureVideoPreviewLayer {
        scanner.getPreviewLayer()
    }
    
    func startScanningSession() { scanner.startScanning() }
    
    func stopScanningSession() { scanner.stopScanning() }
    
    func toggleFlashlight() {
        isFlashlightOn.toggle()
        scanner.toggleFlashlight(status: isFlashlightOn)
    }
    
    func decodeQrCode(from image: UIImage) { scanner.decodeQrCodeFromStaticImage(from: image) }
    
    
    func configureGoogleService(_ dbService: DatabaseService) async throws {
        try await self.spreadsheetsService.configure()
        self.dbService = dbService
    }
    
    func confirmAndAppendToSpreadsheet() async {
        guard let parts = qrCodeResult?.value else { return }
        Task { await appendToSpreadsheet(parts)}
    }
    
    func appendToSpreadsheet(_ parts: [String]) async {
        do {
            guard (selection.getSelectedSpreadsheet() != nil),
            (selection.getSelectedSheet() != nil) else {
                uiError = .generic(message: "Please select a spreadsheet and a sheet!")
                return
            }
            
            try await sheets.appendDataToSheet(qrCodeData: parts)
            // save?
            qrCodeResult = nil
        } catch {
            uiError = .generic(message: error.localizedDescription)
        }
    }
    
    private func save(parts: [String]) async {
        
    }
    
    
    @MainActor
    func saveQrCodeData() {
        if let result = qrCodeResult {
            dbService?.creatQrCodeData(with: result.value.joined(separator: qrCodeSettingsService.qrCodeDelimiter ?? ""), timestamp: Date())
        }
    }
}
