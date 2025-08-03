//
//  QRCodeResultField.swift
//  InventoryManager
//
//  Created by Milan Parađina on 03.08.2025..
//

import SwiftUI

struct QRCodeResultField: View {
    let labelText: String
    let detailsText: String
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(labelText)
                .font(.headline)
                .fontWeight(.semibold)
            
            Text(detailsText)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            
            Divider()
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.secondary.opacity(0.1))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
}

#Preview {
    QRCodeResultField(labelText: "Item 1", detailsText: "Item deets")
}
