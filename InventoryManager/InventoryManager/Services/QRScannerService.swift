//
//  QRScannerService.swift
//  InventoryManager
//
//  Created by Milan Parađina on 02.08.2025..
//

import Foundation
import AVFoundation
import UIKit
import Combine

final class QRScannerService: NSObject, ObservableObject, QRScanning {
    
    private let session = AVCaptureSession()
    private let metadataOutput = AVCaptureMetadataOutput()
    
    private let scannedSubject = PassthroughSubject<String?, Never>()
    var scannedQrCodePublisher: AnyPublisher<String?, Never>? {
        scannedSubject.eraseToAnyPublisher()
    }
    
    private var lastEmitted: String?
    
    func startScanning() {
        guard let videoDevice = AVCaptureDevice.default(for: .video),
              let videoInput = try? AVCaptureDeviceInput(device: videoDevice) else {
            debugPrint("[QRScannerService] - Failed to create camera input")
            return
        }
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            
            self.session.beginConfiguration()
            if session.canAddInput(videoInput) {
                session.addInput(videoInput)
            }

            if session.canAddOutput(metadataOutput) {
                session.addOutput(metadataOutput)
                metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
                metadataOutput.metadataObjectTypes = [.qr]
            }
            
            session.commitConfiguration()
            session.startRunning()
        }
    }
    
    func stopScanning() {
        session.stopRunning()
    }
    
    func decodeQrCodeFromStaticImage(from image: UIImage) {
        guard let ciImage = CIImage(image: image) else { return }
        let context = CIContext()
        let detector = CIDetector(ofType: CIDetectorTypeQRCode, context: context, options: nil)
        if let features = detector?.features(in: ciImage),
           let qrCodeFeatures = features.first as? CIQRCodeFeature,
           let value = qrCodeFeatures.messageString {
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                if self.lastEmitted != value {
                    self.lastEmitted = value
                    self.scannedSubject.send(value)
                }
            }
        }
    }
    
    func pauseSession() {
        //todo -> don't stop the stream session
    }

    
    func toggleFlashlight(status flaslightStatus: Bool) {
        guard let device = AVCaptureDevice.default(for: .video),
              device.hasTorch else {
            debugPrint("[QRScannerService] - device has not flashlight!")
            return
        }

        do {
            try device.lockForConfiguration()
            device.torchMode = flaslightStatus ? .on : .off
            device.unlockForConfiguration()
        } catch {
            print("[QRScannerService] Failed to toggle flashlight: \(error)")
        }
    }

    func getPreviewLayer() -> AVCaptureVideoPreviewLayer {
        let layer = AVCaptureVideoPreviewLayer(session: session)
        layer.videoGravity = .resizeAspectFill
        return layer
    }
}

extension QRScannerService: AVCaptureMetadataOutputObjectsDelegate {
    func metadataOutput(_ output: AVCaptureMetadataOutput,
                        didOutput metadataObjects: [AVMetadataObject],
                        from connection: AVCaptureConnection) {
        guard let object = metadataObjects.first as? AVMetadataMachineReadableCodeObject,
              let stringValue = object.stringValue else { return }

        if lastEmitted == stringValue { return }
        lastEmitted = stringValue
        scannedSubject.send(stringValue)
        
        stopScanning()
    }
}
