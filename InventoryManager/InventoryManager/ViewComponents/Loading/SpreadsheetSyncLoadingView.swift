//
//  SpreadsheetSyncLoadingView.swift
//  InventoryManager
//
//  Created by Milan Parađina on 14.08.2025..
//

import SwiftUI

import SwiftUI

struct SpreadsheetLoadingView: View {
    let text: String
    let symbols: [String]
    var interval: TimeInterval = 0.6
    var symbolSize: CGFloat = 42
    var cornerRadius: CGFloat = 20
    var padding: CGFloat = 20
    var background: Material = .ultraThinMaterial
    
    @State private var index: Int = 0
    
    var body: some View {
        HStack(spacing: 16) {
            // Current symbol
            Image(systemName: currentSymbol)
                .font(.system(size: symbolSize, weight: .semibold))
                .symbolEffect(.bounce, options: .repeating, value: index)
                .transition(.scale.combined(with: .opacity))
                .frame(width: symbolSize, height: symbolSize)
                .accessibilityHidden(true)
            
            
            Text(text)
                .font(.headline)
                .multilineTextAlignment(.leading)
                .fixedSize(horizontal: false, vertical: true)
                .accessibilityLabel(text)
        }
        .padding(padding)
        .background(background, in: RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
        .shadow(radius: 8, y: 4)
        .onAppear { startCycling() }
        .onChange(of: symbols) { _ in index = 0 } // reset when symbols change
        .accessibilityAddTraits(.isStaticText)
    }
    
    private var currentSymbol: String {
        guard !symbols.isEmpty else { return "hourglass.circle" }
        return symbols[index % symbols.count]
    }
    
    private func startCycling() {
        guard symbols.count > 1 else { return }
        // Timer-based index advance; keeps working across iOS versions
        Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { _ in
            withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                index = (index + 1) % symbols.count
            }
        }
    }
}


#Preview {
    SpreadsheetLoadingView(text: "Hang tight!", symbols: ["document.on.document.fill", "document.viewfinder.fill"])
}
