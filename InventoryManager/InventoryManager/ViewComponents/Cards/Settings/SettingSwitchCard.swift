//
//  SettingSwitchCard.swift
//  InventoryManager
//
//  Created by Milan Parađina on 22.08.2025..
//

import SwiftUI

struct SettingSwitchCard: View {
    let symbol: String
    let switchText: String
    @Binding var isOn: Bool
    
    var body: some View {
        HStack {
            Image(systemName: symbol)
                .font(.title2)
                .fontWeight(.semibold)
                .symbolEffect(.wiggle, isActive: true)
                .padding(.leading, 8)
            
            Toggle(isOn: $isOn) {
                Text(switchText)
            }
            .tint(Color.purple.opacity(0.30))
            .padding()
        }
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 16))
        .shadow(radius: 2, y: 1)
    }
}

#Preview {
    @Previewable @State var isOn: Bool = false
    SettingSwitchCard(symbol: "qrcode",switchText: "Save to device on dismiss", isOn: $isOn)
        .padding()
}
