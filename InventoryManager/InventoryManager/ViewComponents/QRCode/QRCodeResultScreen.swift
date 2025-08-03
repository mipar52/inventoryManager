//
//  QRCodeResultScreen.swift
//  InventoryManager
//
//  Created by Milan Parađina on 03.08.2025..
//

import SwiftUI

struct QRCodeResultScreen: View {
    @Environment (\.dismiss) var dismiss
    
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
                List {
                    ForEach(lines, id: \.self) { line in
                        QRCodeResultField(labelText: "Result", detailsText: line)
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
            Button {
                Task {
                    do {
                        try await viewModel.appendToSpreadsheet()
                        dismiss()
                    } catch {
                        errorMessage = error.localizedDescription
                        showErrorToast.toggle()
                    }
                }
            } label: {
                Text("Send to Spreadsheet")
            }

        }
        .onAppear(perform: {
            Task {
                do {
                    try await viewModel.configureGoogleService()
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
    QRCodeResultScreen(viewModel: ScannerViewModel())
}
