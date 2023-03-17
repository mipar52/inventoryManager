//
//  ScannerController.swift
//  InventoryManager
//
//  Created by Milan Parađina on 17.03.2023..
//

import AVFoundation
import UIKit

class ScannerViewController: UIViewController {

    var captureSession: AVCaptureSession!
    var previewLayer: AVCaptureVideoPreviewLayer!

    var headerView = UIView()
    var scannerView = UIView()
    let uiLabel = UILabel()
    
    let cameraQueue = DispatchQueue(label: "cameraQueue")
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViewConstraints()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if (captureSession?.isRunning == false) {
            cameraQueue.async { [weak self] in
                self?.captureSession.startRunning()
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopScanning()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        startScanning()
    }
    
    func failed() {
        let ac = UIAlertController(title: "Scanning not supported", message: "Your device does not support scanning a code from an item. Please use a device with a camera.", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
        captureSession = nil
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
}

extension ScannerViewController: AVCaptureMetadataOutputObjectsDelegate {
    
    func startScanning() {
        captureSession = AVCaptureSession()
        view.backgroundColor = UIColor.black
        captureSession = AVCaptureSession()

        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else { return }
        let videoInput: AVCaptureDeviceInput

        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch {
            return
        }

        if (captureSession.canAddInput(videoInput)) {
            captureSession.addInput(videoInput)
        } else {
            failed()
            return
        }

        let metadataOutput = AVCaptureMetadataOutput()

        if (captureSession.canAddOutput(metadataOutput)) {
            captureSession.addOutput(metadataOutput)

            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [.qr]
        } else {
            failed()
            return
        }

        let scannerOverlayPreviewLayer = ScannerOverlayPreviewLayer(session: captureSession)
        scannerView.layer.frame = view.layer.bounds
        scannerOverlayPreviewLayer.frame = scannerView.bounds
        scannerOverlayPreviewLayer.videoGravity = .resizeAspectFill
        scannerView.layer.addSublayer(scannerOverlayPreviewLayer)
        
        let label = UILabel()
        label.font = UIFont(name: "Helvetica-Bold", size: 20)
       // label.frame = CGRect(x: 100, y: 200, width: scannerOverlayPreviewLayer.bounds.width, height: scannerOverlayPreviewLayer.bounds.height)
        label.frame = CGRect(x: scannerOverlayPreviewLayer.frame.origin.x + 100, y: scannerOverlayPreviewLayer.frame.origin.y + 150, width: scannerOverlayPreviewLayer.bounds.width, height: scannerOverlayPreviewLayer.bounds.height )
        label.text = "Scan the QR code"
        label.textColor = UIColor.white
        label.isHidden = false
        scannerView.layer.addSublayer(label.layer)
        
        uiLabel.center = scannerView.center
        scannerView.addSubview(uiLabel)
        
        metadataOutput.rectOfInterest = scannerOverlayPreviewLayer.rectOfInterest
        
        cameraQueue.async { [weak self] in
            self?.captureSession.startRunning()
        }
    }
    
    func setupViewConstraints() {
        view.addSubview(headerView)
        view.addSubview(scannerView)

        headerView.translatesAutoresizingMaskIntoConstraints = false
        scannerView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor),
            headerView.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
            headerView.bottomAnchor.constraint(equalTo: scannerView.topAnchor),
            headerView.heightAnchor.constraint(equalToConstant: 200),
            scannerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scannerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scannerView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    func stopScanning() {
        if (captureSession?.isRunning == true) {
            cameraQueue.async { [weak self] in
                self?.captureSession.stopRunning()
            }
        }
    }
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        captureSession.stopRunning()

        if let metadataObject = metadataObjects.first {
            guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
            guard let stringValue = readableObject.stringValue else { return }
            DispatchQueue.main.async {
                self.showHalfVC(qrCodeResult: stringValue)
            }
            //AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
        }
    }
}

extension ScannerViewController: UIViewControllerTransitioningDelegate {
    @objc func showHalfVC(qrCodeResult: String) {
        let slideVC = OverlayView()
        
        if #available(iOS 15.0, *) {
            slideVC.sheetPresentationController?.detents = [.medium()]
        }
        slideVC.results = qrCodeResult
        slideVC.modalPresentationStyle = .automatic
        slideVC.transitioningDelegate = self
        self.present(slideVC, animated: true, completion: nil)
    }
}
