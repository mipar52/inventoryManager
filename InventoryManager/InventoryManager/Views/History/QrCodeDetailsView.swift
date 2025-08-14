//
//  QrCodeDetailsView.swift
//  InventoryManager
//
//  Created by Milan Parađina on 13.08.2025..
//

import SwiftUI

struct QrCodeDetailsView: View {
    @ObservedObject var viewModel: ScannerViewModel
    
    var body: some View {
        VStack(spacing: 15) {
            Text("Scan details")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            List {
//                ForEach(viewModel.qrCodeResult?.components(separatedBy: .newlines)) { data in
//                    QRCodeResultField(labelText: "Item", detailsText: <#T##String#>)
//                }
            }
        }
    }
}

#Preview {
    QrCodeDetailsView(viewModel: ScannerViewModel())
}
