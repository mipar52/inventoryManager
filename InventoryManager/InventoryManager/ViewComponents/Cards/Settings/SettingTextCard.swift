//
//  SettingTextCard.swift
//  InventoryManager
//
//  Created by Milan Parađina on 22.08.2025..
//

import SwiftUI

struct SettingTextCard: View {
    let symbol: String
    let text: String
    let placeholderText: String
    @Binding var value: String
    
    var body: some View {
        HStack {
            Image(systemName: symbol)
                .font(.title2)
                .padding(.leading, 8)
                .symbolEffect(.wiggle, isActive: true)
            
            Text(text)
                .font(.title3)
                .fontWeight(.semibold)
                        
            TextField(placeholderText, text: $value)
                .frame(maxWidth: .infinity, minHeight: 44)
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 8))
                .multilineTextAlignment(.center)
                .padding(.all, 10)
        }
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
        .shadow(radius: 8)
    }
}

#Preview {
    @Previewable @State var text: String = "bla"
    SettingTextCard(symbol: "pencil", text: "QR code delimiter", placeholderText: "do something", value: $text)
}
