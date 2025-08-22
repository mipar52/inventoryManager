//
//  QrCodeSettingsView.swift
//  InventoryManager
//
//  Created by Milan Parađina on 14.08.2025..
//

import SwiftUI

struct QrCodeSettingsView: View {
    @State var delimiter: String = ""
    @State var isOn: Bool = false
    @State var isOnTwo: Bool = true
    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(colors: [.purple.opacity(0.18), .blue.opacity(0.18)], startPoint: .topLeading, endPoint: .bottomTrailing)
                    .ignoresSafeArea(.all)
                
                ScrollView {
                    SettingTextCard(symbol: "pencil", text: "QR Code delimiter", placeholderText: "':' or ';'", value: $delimiter)
                    SettingSwitchCard(symbol: "checkmark.seal.text.page.fill", switchText: "Accept QR codes with specific text", isOn: $isOn)
                    if isOn {
                            Group {
                                SettingTextCard(symbol: "character.cursor.ibeam", text: "QR Code acceptance text", placeholderText: "Apple", value: $delimiter)
                                SettingSwitchCard(symbol: "x.circle", switchText: "Ignore the acceptance text from result", isOn: $isOnTwo)
                            }
                            .transition(.opacity.combined(with: .move(edge: .top)))
                            .padding(.top, 8)
                    }
                }
                .animation(.easeIn(duration: 0.2), value: isOn)
                .navigationTitle("QR code settings")
                .navigationBarTitleDisplayMode(.large)
                .padding()
            }
        }
    }
}

#Preview {
    QrCodeSettingsView()
}
