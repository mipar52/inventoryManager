//
//  ScanPickerView.swift
//  InventoryManager
//
//  Created by Milan Parađina on 01.08.2025..
//

import SwiftUI

struct ScanPickerView: View {
   @ObservedObject var scannerViewModel: ScannerViewModel = ScannerViewModel()
    @EnvironmentObject private var selectionService: SelectionService
//    @ObservedObject var spreadsheetViewModel: SpreadsheetPickerViewModel = SpreadsheetPickerViewModel(selectionService: selectionService)
    
    var body: some View {
        
        NavigationView {
            VStack {
                NavigationLink {
                    QRScanStreamView(scannerViewModel: scannerViewModel, spreadsheetPickerViewModel: SpreadsheetPickerViewModel(selectionService: selectionService))
                } label: {
                    Text("Scanner")
                }
                
                NavigationLink {
                    PhotoPickerView(scannerViewModel: scannerViewModel, spreadsheetViewModel: SpreadsheetPickerViewModel(selectionService: selectionService))
                } label: {
                    Text("Photo picker")
                }
            }
        }
    }
}

#Preview {
    //ScanPickerView()
}
