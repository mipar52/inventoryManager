//
//  ScanSettingsView.swift
//  InventoryManager
//
//  Created by Milan Parađina on 14.08.2025..
//

import SwiftUI

struct ScanSettingsView: View {
    @State private var isOn = false
    
    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(colors: [.purple.opacity(0.18), .blue.opacity(0.18)], startPoint: .topTrailing, endPoint: .bottomLeading)
                    .ignoresSafeArea(.all)

                ScrollView {
                    SettingSwitchCard(symbol: "square.and.arrow.down.on.square", switchText: "Save data on dismiss", isOn: $isOn)
                    SettingSwitchCard(symbol: "square.and.arrow.down.on.square", switchText: "Save data on scanning error", isOn: $isOn)
                    SettingSwitchCard(symbol: "eye.fill", switchText: "Show QR result screen", isOn: $isOn)
//                    SettingSwitchCard(symbol: "square.and.arrow.down.on.square", switchText: "Save data on dismiss", isOn: $isOn)
//                    SettingSwitchCard(symbol: "square.and.arrow.down.on.square", switchText: "Save data on dismiss", isOn: $isOn)
//                    SettingSwitchCard(symbol: "square.and.arrow.down.on.square", switchText: "Save data on dismiss", isOn: $isOn)
                }
                .padding()
                .navigationTitle("Scan settings")
                .navigationBarTitleDisplayMode(.large)
            }
        }
    }
}

#Preview {
    ScanSettingsView()
}
