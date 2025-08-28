//
//  QRScanning.swift
//  InventoryManager
//
//  Created by Milan Parađina on 27.08.2025..
//

import AVFoundation
import Combine
import UIKit

protocol QRScanning {
    var scannedQrCodePublisher: AnyPublisher<String?, Never>? { get }
    func startScanning()
    func stopScanning()
    func toggleFlashlight(status: Bool)
    func getPreviewLayer() -> AVCaptureVideoPreviewLayer
    func decodeQrCodeFromStaticImage(from image: UIImage)
}
