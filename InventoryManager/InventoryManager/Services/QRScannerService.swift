//
//  QRScannerService.swift
//  InventoryManager
//
//  Created by Milan Parađina on 02.08.2025..
//

import Foundation
import AVFoundation
import UIKit

final class QRScannerService: NSObject, ObservableObject {
    private let session = AVCaptureSession()
    private let metadataOutput = AVCaptureMetadataOutput()
    
    @Published var scannedCode: String?
    
    func startSession() {
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

    func stopSession() {
        session.stopRunning()
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
    
    /// Used for the image picker
    func decodeQRCodeFromStaticImage(from image: UIImage) {
        guard let ciImage = CIImage(image: image) else { return }
        let context = CIContext()
        let detector = CIDetector(ofType: CIDetectorTypeQRCode, context: context, options: nil)
        if let features = detector?.features(in: ciImage),
           let qrCodeFeatures = features.first as? CIQRCodeFeature {
            scannedCode = qrCodeFeatures.messageString
        }
    }
}

extension QRScannerService: AVCaptureMetadataOutputObjectsDelegate {
    func metadataOutput(_ output: AVCaptureMetadataOutput,
                        didOutput metadataObjects: [AVMetadataObject],
                        from connection: AVCaptureConnection) {
        guard let object = metadataObjects.first as? AVMetadataMachineReadableCodeObject,
              let stringValue = object.stringValue else { return }

        scannedCode = stringValue
        stopSession()
    }
}
