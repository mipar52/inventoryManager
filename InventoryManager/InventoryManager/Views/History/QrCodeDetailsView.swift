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
    
    @State private var isLoading: Bool = false
    @State private var isSuccess: Bool = false
    @State private var alertMessage: String = ""
    @State private var loadingMessage: String = ""
    
    var body: some View {
        ZStack {
            LinearGradient(colors: [Color.purple.opacity(0.18), Color.blue.opacity(0.18)],
                           startPoint: .topLeading, endPoint: .bottomTrailing)
            .ignoresSafeArea()
            
            VStack(spacing: 15) {
                Text("Scan details")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                    if let text = qrCodeData.stringData,
                       let timestamp = qrCodeData.timestamp {
                        ScrollView {
                       // List {
                            ForEach(text.components(separatedBy: .newlines), id: \.self) { data in
                                QRCodeResultField(labelText: "Item", detailsText: data, symbolImage: "qrcode")
                            }
                            QRCodeResultField(labelText: "Scan taken", detailsText: timestamp.description, symbolImage: "calendar")
                        }
                        .padding()
                       // .scrollContentBackground(.hidden)
                        
                    } else {
                        EmptyStateView()
                    }
            }
            .safeAreaInset(edge: .bottom, content: {
                
                    if let _ = qrCodeData.stringData,
                       let _ = qrCodeData.timestamp {
                        VStack(spacing: 15) {
                            Button {
                                Task {
                                    do {
                                        loadingMessage = "Sending to Sheet..\nHold on a sec.."
                                        isLoading.toggle()
                                        try await vm.sendItem(item: qrCodeData)
                                        isLoading.toggle()
                                    } catch {
                                        isLoading.toggle()
                                        alertMessage = error.localizedDescription
                                        debugPrint(error.localizedDescription)
                                    }
                                }
                            } label: {
                                Text("Send information to Sheet")
                                    .frame(maxWidth: .infinity, minHeight: 50)
                                    .fontWeight(.bold)
                            }
                            .buttonStyle(.borderedProminent)
                            .tint(.green)
                            
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
                                    .frame(maxWidth: .infinity, minHeight: 50)
                                    .fontWeight(.bold)
                            }
                            .buttonStyle(.borderedProminent)
                            .tint(.red)
                        }
                        .padding()
                    }
            })
            .loadingOverlay($isLoading, text: loadingMessage, symbols: ["paperplane.fill", "paperplane"])
            .alert(Text("Success"), isPresented: $isSuccess) {
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
                    Text("Delete")
                }
                
                Button(role: .cancel) {
                    
                } label: {
                    Text("Cancel")
                }
            } message: {
                Text("Item sent do Sheet successfully!\nDo you wish to delete it?")
            }

            
        }
    }
}

#Preview {
  //  QrCodeDetailsView(viewModel: ScannerViewModel())
}
