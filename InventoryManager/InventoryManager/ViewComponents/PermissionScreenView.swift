//
//  PermissionScreenView.swift
//  InventoryManager
//
//  Created by Milan Parađina on 14.08.2025..
//

import SwiftUI

struct PermissionHintView: View {
    @State private var show = true
    var body: some View {
        if show {
            HStack(spacing: 10) {
                Image(systemName: "camera.fill")
                    .symbolRenderingMode(.palette)
                    .foregroundStyle(.white, .blue)
                VStack(alignment: .leading) {
                    Text("Allow Camera for Live Scan").font(.subheadline).bold()
                    Text("You can enable it in Settings anytime.").font(.caption).foregroundStyle(.secondary)
                }
                Spacer()
                Button("Dismiss") { withAnimation { show = false } }
                    .font(.caption)
            }
            .padding(12)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 14))
            .transition(.move(edge: .bottom).combined(with: .opacity))
        }
    }
}

#Preview {
    PermissionHintView()
}
