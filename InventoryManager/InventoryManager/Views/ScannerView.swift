//
//  ScannerView.swift
//  InventoryManager
//
//  Created by Milan Parađina on 02.08.2025..
//

import SwiftUI

struct ScannerView: UIViewRepresentable {
    @ObservedObject var scannerViewModel: ScannerViewModel

    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        let previewLayer = scannerViewModel.getPreviewLayer()
        previewLayer.frame = UIScreen.main.bounds
        view.layer.addSublayer(previewLayer)
        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {}
}
