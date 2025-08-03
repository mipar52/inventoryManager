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
    
    @Published var qrCodeResult: String? = nil
   //  private var cancellables = Set<AnyCancellable>() -> don't need it as you're using assing
    
    init(qrCodeScannerService: QRScannerService = QRScannerService()) {
        self.qrCodeScannerService = qrCodeScannerService
        super.init()
        self.bindService()
    }
    
    private func bindService() {
        qrCodeScannerService.$scannedCode
            .receive(on: DispatchQueue.main)
            .assign(to: &$qrCodeResult)
        
//        qrCodeScannerService.$scannedCode
//            .sink { qrCode in
//                qrCodeResult = qrCode
//            }
//            .store(in: &cancellables)
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
