//
//  QrCodeDetailsView.swift
//  InventoryManager
//
//  Created by Milan Parađina on 13.08.2025..
//

import SwiftUI

struct QrCodeDetailsView: View {
    
    @Environment(\.dismiss) var dismiss
    @StateObject var vm: ScanDetailsViewModel
    let qrCodeData: QRCodeData
    
    var body: some View {
        VStack(spacing: 15) {
            Text("Scan details")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            List {
                if let text = qrCodeData.stringData,
                   let timestamp = qrCodeData.timestamp {
                    ScrollView {
                        ForEach(text.components(separatedBy: .newlines), id: \.self) { data in
                            QRCodeResultField(labelText: "Item", detailsText: data)
                        }
                        QRCodeResultField(labelText: "Scan taken", detailsText: timestamp.description)
                    }
                    
                    Spacer()
                    
                    VStack(spacing: 15) {
                        Button {
                            Task {
                                do {
                                    try await vm.sendItem(item: qrCodeData)
                                } catch {
                                    debugPrint(error.localizedDescription)
                                }
                            }
                        } label: {
                            Text("Send information to Sheet")
                        }
                        
                        Button(role: .destructive) {
                            Task {
                                do {
                                    try await vm.deleteItem(item: qrCodeData)
                                    dismiss()
                                } catch {
                                    debugPrint(error.localizedDescription)
                                }
                            }
                        } label: {
                            Text("Delete item")
                        }
                    }
                } else {
                    EmptyStateView()
                }
            }
        }
    }
}

#Preview {
  //  QrCodeDetailsView(viewModel: ScannerViewModel())
}
