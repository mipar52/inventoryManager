//
//  QRRecticleOverlay.swift
//  InventoryManager
//
//  Created by Milan Parađina on 14.08.2025..
//

import SwiftUI

struct QRRecticleOverlay: View {
    @State private var scanLinePhase: CGFloat = 0

    var body: some View {
        GeometryReader { geo in
            let size = min(geo.size.width, geo.size.height) * 0.68
            let rect = CGRect(
                x: (geo.size.width - size) / 2,
                y: (geo.size.height - size) / 2,
                width: size,
                height: size
            )
            ZStack {
                Rectangle()
                    .fill(.black.opacity(0.35))
                    .mask(
                        ZStack {
                            Rectangle().fill(.black)
                            RoundedRectangle(cornerRadius: 16)
                                .frame(width: rect.width, height: rect.height)
                                .offset(x: rect.minX - geo.size.width/2 + rect.width/2,
                                        y: rect.minY - geo.size.height/2 + rect.height/2)
                                .blendMode(.destinationOut)
                        }
                    )
                    .compositingGroup()

                RoundedRectangle(cornerRadius: 16)
                    .strokeBorder(style: StrokeStyle(lineWidth: 2, lineCap: .round, dash: [6, 6]))
                    .foregroundStyle(.white.opacity(0.5))
                    .frame(width: rect.width, height: rect.height)

                Rectangle()
                    .fill(LinearGradient(colors: [.white.opacity(0), .white.opacity(0.8), .white.opacity(0)],
                                         startPoint: .leading, endPoint: .trailing))
                    .frame(width: rect.width - 24, height: 2)
                    .offset(y: 0)
                    .offset(x: scanLineOffset(for: rect))
                    .mask(
                        RoundedRectangle(cornerRadius: 14)
                            .frame(width: rect.width - 16, height: rect.height - 16)
                    )
                    .onAppear {
                        withAnimation(.linear(duration: 1.8).repeatForever(autoreverses: false)) {
                            scanLinePhase = 1
                        }
                    }

                Image(systemName: "viewfinder")
                    .font(.system(size: 80, weight: .bold))
                    .symbolEffect(.pulse.byLayer, options: .repeat(.periodic(Int(1.8))))
                    .foregroundStyle(.white.opacity(0.85))
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .allowsHitTesting(false)
    }
    
    private func scanLineOffset(for rect: CGRect) -> CGFloat {
        let travel = rect.width - 24
        return (scanLinePhase * travel) - travel / 2
    }
  }

#Preview {
    QRRecticleOverlay()
}
