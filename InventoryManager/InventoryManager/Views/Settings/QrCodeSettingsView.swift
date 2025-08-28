//
//  QrCodeSettingsView.swift
//  InventoryManager
//
//  Created by Milan Parađina on 14.08.2025..
//

import SwiftUI

struct QrCodeSettingsView: View {
    @StateObject var vm: QrCodeSettingsViewModel
    
    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(colors: [.purple.opacity(0.18), .blue.opacity(0.18)], startPoint: .topLeading, endPoint: .bottomTrailing)
                    .ignoresSafeArea(.all)
                
                ScrollView {
                    SettingTextCard(symbol: "pencil", text: "QR Code delimiter", placeholderText: "':' or ';'", value: $vm.qrCodeDelimiter)
                    
                    SettingSwitchCard(symbol: "checkmark.seal.text.page.fill", switchText: "Accept QR codes with specific text", isOn: $vm.acceptQrWithSpecificText)
                    
                    if vm.acceptQrWithSpecificText {
                        Group {
                            SettingTextCard(symbol: "character.cursor.ibeam", text: "QR Code acceptance text", placeholderText: "Apple", value: $vm.qrAcceptanceText)
                            
                            SettingSwitchCard(symbol: "x.circle", switchText: "Ignore the acceptance text from result", isOn: $vm.ignoreQrAcceptanceText)
                        }
                        .transition(.opacity.combined(with: .move(edge: .top)))
                        .padding(.top, 8)
                    }
                }
                .animation(.easeIn(duration: 0.2), value: vm.acceptQrWithSpecificText)
                .navigationTitle("QR code settings")
                .navigationBarTitleDisplayMode(.large)
                .padding()
            }
            .scrollDismissesKeyboard(.immediately)
        }
    }
}

#Preview {
    QrCodeSettingsView(vm: QrCodeSettingsViewModel())
}
