//
//  FeatureCard.swift
//  InventoryManager
//
//  Created by Milan Parađina on 14.08.2025..
//

import SwiftUI

struct FeatureCard: View {
    
    let title: String
    let subtitle: String
    let systemImage: String
    let isPressed: Bool

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: systemImage)
                .font(.system(size: 28, weight: .semibold))
                .symbolRenderingMode(.palette)
                .foregroundStyle(.white, .purple)
                .frame(width: 52, height: 52)
                .background(
                    Circle().fill(.ultraThinMaterial)
                )
                // idle micro-motion & tap bounce
                .symbolEffect(.pulse.byLayer, options: .repeat(.periodic(Int(1.8))))
                .symbolEffect(.bounce, value: isPressed)

            VStack(alignment: .leading, spacing: 4) {
                Text(title).font(.headline)
                Text(subtitle).font(.subheadline).foregroundStyle(.secondary)
            }
            Spacer()
            Image(systemName: "chevron.right")
                .foregroundStyle(.secondary)
        }
        .padding(16)
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .strokeBorder(.white.opacity(0.15))
        )
        .shadow(radius: 2, y: 1)
        .contentShape(Rectangle())
    }
}

#Preview {
    FeatureCard(title: "BLa", subtitle: "bla", systemImage: "qrcode", isPressed: true)
}
