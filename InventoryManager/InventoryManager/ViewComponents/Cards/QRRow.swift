//
//  QRRow.swift
//  InventoryManager
//
//  Created by Milan Parađina on 20.08.2025..
//

import SwiftUI

struct QRRow: View {
    let item: QRCodeData
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "qrcode.viewfinder")
                .symbolRenderingMode(.palette)
                .foregroundStyle(.white, .purple)
                .frame(width: 36, height: 36)
                .background(Circle().fill(.ultraThinMaterial))
                .symbolEffect(.bounce.wholeSymbol, isActive: true)
                .symbolEffect(.rotate.clockwise, isActive: true)
            VStack(alignment: .leading, spacing: 4) {
                Text(item.stringData ?? "—")
                    .font(.system(.body, design: .monospaced))
                    .lineLimit(2)
                Text(relativeTime)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
//            Image(systemName: "chevron.right")
//                .foregroundStyle(.tertiary)
        }
        .padding(.vertical, 6)
    }
    
    private var relativeTime: String {
        let date = item.timestamp ?? Date()
        let r = RelativeDateTimeFormatter()
        r.unitsStyle = .short
        return r.localizedString(for: date, relativeTo: Date())
    }
}

#Preview {
//    QRRow()
}
