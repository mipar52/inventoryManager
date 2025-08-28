//
//  ScanHistorySection.swift
//  InventoryManager
//
//  Created by Milan Parađina on 21.08.2025..
//

import SwiftUI

struct ScanHistorySection: View {
    let title: String
    let scannedItems: [QRCodeData]
    let vm: ScanHistoryViewModel
    
    
    
    var body: some View {
        Section(header:
                    Text(title)
            .font(.subheadline)
            .foregroundStyle(.secondary)
        ) {
            ForEach(scannedItems, id: \.objectID) { item in
                ScanHistoryRow(vm: vm, scannedItem: item)
            }
        }
    }
}

#Preview {
    ScanHistorySection(
        title: "bla",
        scannedItems: [],
        vm: ScanHistoryViewModel(db: DatabaseService())
    )
}
