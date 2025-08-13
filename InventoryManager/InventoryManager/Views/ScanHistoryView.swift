//
//  ScanHistoryView.swift
//  InventoryManager
//
//  Created by Milan Parađina on 01.08.2025..
//

import SwiftUI

struct ScanHistoryView: View {
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(key: "timestamp", ascending: true)],
        animation: .easeInOut
    )
    private var qrCodedata: FetchedResults<QRCodeData>
    var body: some View {
        List {
            ForEach(qrCodedata, id: \.objectID) { qrCode in
                VStack {
                    Text(qrCode.stringData ?? "no data")
                        .font(.headline)
                        .padding(.horizontal)
                    Text(qrCode.timestamp?.description ?? "no timestamp")
                }
            }
        }
    }
}

#Preview {
    ScanHistoryView()
}
