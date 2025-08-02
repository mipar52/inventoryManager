//
//  ScanPickerView.swift
//  InventoryManager
//
//  Created by Milan Parađina on 01.08.2025..
//

import SwiftUI

struct ScanPickerView: View {    
    var body: some View {
        
        NavigationView {
            VStack {
                NavigationLink {
                    QRScanStreamView()
                } label: {
                    Text("Scanner")
                }
            }
        }
    }
}

#Preview {
    ScanPickerView()
}
