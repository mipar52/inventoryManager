//
//  SpreadsheetSyncCard.swift
//  InventoryManager
//
//  Created by Milan Parađina on 14.08.2025..
//

import SwiftUI

struct SpreadsheetSyncCard: View {

    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: "arrow.trianglehead.2.clockwise.rotate.90.circle")
                .font(.title)
                .symbolEffect(.rotate.clockwise, isActive: true)
                .foregroundStyle(.purple)
                .padding(.horizontal)
            
            Text("Sync Spreadsheets from your Google Drive")
                .font(.subheadline)
            Spacer()
        }
        .padding()
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
    SpreadsheetSyncCard()
}
