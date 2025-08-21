//
//  ScanHistoryRow.swift
//  InventoryManager
//
//  Created by Milan Parađina on 21.08.2025..
//

import SwiftUI

struct ScanHistoryRow: View {
    let vm: ScanHistoryViewModel
    let scannedItem: QRCodeData
    
    var body: some View {
        NavigationLink {
            QrCodeDetailsView(
                vm: ScanDetailsViewModel(
                    sheetService: vm.sheetService,
                    db: vm.db),
                qrCodeData: scannedItem)
        } label: {
            QRRow(item: scannedItem)
        }
        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
            
            Button(role: .destructive) {
                do { try vm.deleteItem(item: scannedItem)}
                catch {debugPrint(error.localizedDescription)}
            } label: {
                Label("Delete", systemImage: "trash")
            }
            
            Button {
                UIPasteboard.general.string = scannedItem.stringData
            } label: {
                Label("Copy data", systemImage: "doc.on.doc")
            }
        }
        .contextMenu {
            Button {
                UIPasteboard.general.string = scannedItem.stringData
            } label: {
                Label("Copy QR data", systemImage: "doc.on.doc")
            }
            
            if let text = scannedItem.stringData {
                ShareLink(item: text) {
                    Label("Share", systemImage: "square.and.arrow.up")
                }
            }
        }
    }
}

#Preview {
    ScanHistoryRow(
        vm: ScanHistoryViewModel(db: DatabaseService()),
        scannedItem: QRCodeData(context:
                                    DatabaseService().container.viewContext))
}
