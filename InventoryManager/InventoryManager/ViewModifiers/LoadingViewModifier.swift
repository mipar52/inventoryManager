//
//  LoadingViewModifier.swift
//  InventoryManager
//
//  Created by Milan Parađina on 02.08.2025..
//

import Foundation
import SwiftUI

struct LoadingOverlayModifier: ViewModifier {
    @Binding var isPresented: Bool
    let text: String
    let symbols: [String]
    var dimOpacity: Double = 0.25

    func body(content: Content) -> some View {
        ZStack {
            content
                .disabled(isPresented)
                .overlay {
                    if isPresented {
                        Rectangle()
                            .fill(.black.opacity(dimOpacity))
                            .ignoresSafeArea()
                            .transition(.opacity)
                            .accessibilityHidden(true)

                        SpreadsheetLoadingView(text: text, symbols: symbols)
                            .transition(.scale.combined(with: .opacity))
                            .accessibilityElement(children: .combine)
                            .accessibilityAddTraits(.isModal)
                    }
                }
                .animation(.easeInOut(duration: 0.2), value: isPresented)
        }
    }
}

extension View {
    func loadingOverlay(
        _ isPresented: Binding<Bool>,
        text: String,
        symbols: [String],
        dimOpacity: Double = 0.25
    ) -> some View {
        modifier(
            LoadingOverlayModifier(
                isPresented: isPresented,
                text: text,
                symbols: symbols,
                dimOpacity: dimOpacity
            )
        )
    }
}

