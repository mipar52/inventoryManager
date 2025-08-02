//
//  QRScannerService.swift
//  InventoryManager
//
//  Created by Milan Parađina on 02.08.2025..
//

import Foundation
import AVFoundation

final class QRScannerService: NSObject, ObservableObject {
    private let session = AVCaptureSession()
    private let metadataOutput = AVCaptureMetadataOutput()
    
    @Published var scannedCode: String?
    @Published var flashlightPressed: Bool = false
    
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
    
    func toggleFlashlight() {
        guard let device = AVCaptureDevice.default(for: .video),
              device.hasTorch else {
            debugPrint("[QRScannerService] - device has not flashlight!")
            return
        }

        do {
            try device.lockForConfiguration()
            flashlightPressed.toggle()
            device.torchMode = flashlightPressed ? .on : .off
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

        scannedCode = stringValue
        stopSession()
    }
}
