//
//  EmptyStateView.swift
//  InventoryManager
//
//  Created by Milan Parađina on 20.08.2025..
//

import SwiftUI

struct EmptyStateView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "qrcode.viewfinder")
                .font(.system(size: 56))
                .symbolRenderingMode(.palette)
                .foregroundStyle(.white.opacity(0.9), .purple)
                .symbolEffect(.pulse.byLayer, options: .repeat(.periodic(Int(1.8))))
            Text("No scans yet")
                .font(.title3).bold()
            Text("Scan a code using Live Scan or pick a photo to get started.")
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
        }
        .padding()
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 16))
    }
}

#Preview {
    EmptyStateView()
}
