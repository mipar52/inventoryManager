//
//  ScanPickerView.swift
//  InventoryManager
//
//  Created by Milan Parađina on 01.08.2025..
//

import SwiftUI

struct ScanPickerView: View {
   @ObservedObject var scannerViewModel: ScannerViewModel = ScannerViewModel()
    
    var body: some View {
        
        NavigationView {
            VStack {
                NavigationLink {
                    QRScanStreamView(scannerViewModel: scannerViewModel)
                } label: {
                    Text("Scanner")
                }
                
                NavigationLink {
                    PhotoPickerView(scannerViewModel: scannerViewModel)
                } label: {
                    Text("Photo picker")
                }
            }
        }
    }
}

#Preview {
    ScanPickerView()
}
