//
//  ToastView.swift
//  InventoryManager
//
//  Created by Milan Parađina on 03.08.2025..
//

import SwiftUI

struct ToastView: View {
    let labelText: String
    var body: some View {
        Text(labelText)
            .padding()
            .background(.ultraThinMaterial)
            .cornerRadius(12)
            .padding(.bottom, 30)
    }
}

#Preview {
    ToastView(labelText: "Hello!")
}
