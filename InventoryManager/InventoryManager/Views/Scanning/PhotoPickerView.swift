//
//  PhotoPickerView.swift
//  InventoryManager
//
//  Created by Milan Parađina on 03.08.2025..
//

import SwiftUI
import PhotosUI

struct PhotoPickerView: View {
    @ObservedObject var scannerViewModel: ScannerViewModel
    @ObservedObject var spreadsheetViewModel: SpreadsheetPickerViewModel
    @State private var item: PhotosPickerItem?
    @State private var uiImage: UIImage?
    @State private var showToastError: Bool = false
    
    var body: some View {
        VStack {
            SpreadsheetPicker(viewModel: spreadsheetViewModel)
            PhotosPicker("Pick a photo", selection: $item, matching: .images)
            if let image = uiImage {
                VStack {
                    Image(uiImage: image)
                        .resizable()
                        .padding(.horizontal, 10)
                        .scaledToFit()
                        .frame(width: 300, height: 300)
                    
                    Button {
                        scannerViewModel.decodeQrCode(from: image)
                    } label: {
                        Text("Send to sheets")
                    }
                    
//                    if let qrCodeResult = scannerViewModel.qrCodeResult?.value {
//                        ToastView(labelText: qrCodeResult)
//                    }
                }
            }
            
            Spacer()
            
            if showToastError {
                ToastView(labelText: "Could not get image! Please try again")
            }
        }
        .onChange(of: item) {
            Task {
                if let loaded = try? await item?.loadTransferable(type: Data.self) {
                    if let result = UIImage(data: loaded) {
                        uiImage = result
                    }
                } else {
                    showToastError.toggle()
                }
            }
        }
        .sheet(isPresented: $scannerViewModel.isSuccess) {
            QRCodeResultScreen(viewModel: scannerViewModel)
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)
                .padding()
        }
    }
}

#Preview {
   // PhotoPickerView(scannerViewModel: ScannerViewModel())
}
