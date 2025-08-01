//
//  GoogleSignInService.swift
//  InventoryManager
//
//  Created by Milan Parađina on 01.08.2025..
//

import Foundation
import SwiftUI
import GoogleSignIn

struct GoogleSignInService: ViewModifier {
    func body(content: Content) -> some View {
        content
            .onAppear {
                Task {
                    do {
                        try await GoogleAuthManager.shared.restoreSession()
                    } catch {
                        debugPrint("[GoogleSignInError] - \(error.localizedDescription)")
                    }
                }
            }
            .onOpenURL { url in
                Task {
                    await GoogleAuthManager.shared.handleUrl(url)
                }
            }
    }
}

extension View {
    func handleGoogleRestoreSignIn() -> some View {
        modifier(GoogleSignInService())
    }
}
