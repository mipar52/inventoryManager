//
//  QRCodeResultScreen.swift
//  InventoryManager
//
//  Created by Milan Parađina on 03.08.2025..
//

import SwiftUI

struct QRCodeResultScreen: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject private var db: DatabaseService
    
    @ObservedObject var viewModel: ScannerViewModel
    @State var showErrorToast: Bool = false
    @State var errorMessage = ""
    var body: some View {
        VStack {
            Text("QR Code Result")
                .font(.headline)
                .fontWeight(.bold)
            
            if let result = viewModel.qrCodeResult {
                let lines = result.components(separatedBy: .newlines).filter { !$0.isEmpty}
                ScrollView {
                    ForEach(lines, id: \.self) { line in
                        QRCodeResultField(labelText: "Result", detailsText: line, symbolImage: "qrcode")
                    }
                }
            } else {
                Text("Did not manage to extract any data yet!")
                    .font(.caption)
                    .fontWeight(.semibold)
            }
            Spacer()
            if showErrorToast {
                ToastView(labelText: errorMessage)
            }
            
            VStack(spacing: 10) {
                Button {
                    Task {
                        do {
                            try await viewModel.appendToSpreadsheet()
                            viewModel.saveQrCodeData()
                            dismiss()
                        } catch {
                            errorMessage = error.localizedDescription
                            showErrorToast.toggle()
                        }
                    }
                } label: {
                    Text("Send to Spreadsheet")
                        .frame(maxWidth: .infinity, minHeight: 50)
                        .fontWeight(.bold)
                }
                .buttonStyle(.borderedProminent)
                .tint(.green)
                
                Button(role: .cancel) {
                   dismiss()
                } label: {
                    Text("Cancel")
                        .frame(maxWidth: .infinity, maxHeight: 20)
                        .fontWeight(.bold)
                }
                .buttonStyle(.borderedProminent)
                .tint(.red)
            }

        }
        .onAppear(perform: {
            Task {
                do {
                    try await viewModel.configureGoogleService(db)
                } catch {
                    errorMessage = error.localizedDescription
                    showErrorToast.toggle()
                }
            }

        })
        .padding()
    }
}

#Preview {
  //  QRCodeResultScreen(viewModel: ScannerViewModel())
}
