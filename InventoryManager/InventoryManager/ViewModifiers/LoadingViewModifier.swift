//
//  LoadingViewModifier.swift
//  InventoryManager
//
//  Created by Milan Parađina on 02.08.2025..
//

import Foundation
import SwiftUI

struct LoadingOverlayModifier: ViewModifier {
    @Binding var isLoading: Bool

    func body(content: Content) -> some View {
        ZStack {
            content
                .disabled(isLoading)
                .blur(radius: isLoading ? 1 : 0)

            if isLoading {
                Color.black.opacity(0.3)
                    .ignoresSafeArea()

                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .scaleEffect(1.5)
            }
        }
        .animation(.easeInOut, value: isLoading)
    }
}

extension View {
    func withLoadingOverlay(_ isLoading: Binding<Bool>) -> some View {
        self.modifier(LoadingOverlayModifier(isLoading: isLoading))
    }
}
