//
//  QrDataCard.swift
//  InventoryManager
//
//  Created by Milan Parađina on 14.08.2025..
//

import SwiftUI

struct QrDataCard: View {
    let qrData: String?
    let timeStamp: String?
    @State private var timer: Timer?
    @State private var triggerEffect: Bool = false
    var body: some View {
        HStack {
            Image(systemName: "qrcode.viewfinder")
                .font(.title)
//                .cornerRadius(16)
//                .containerShape(Circle())
                .padding(.horizontal)
                .symbolEffect(.breathe, value: triggerEffect)
                .symbolEffect(.rotate.clockwise, value: triggerEffect)
            
            VStack(alignment: .leading) {
                Group {
                    Text(qrData ?? "No data")
                        .font(.headline)
                    
                    Text(timeStamp ?? "No date provided")
                        .font(.subheadline)
                }
            }
            .padding()
            Spacer()
        }
        .containerShape(Rectangle())
        .cornerRadius(16)
        .onAppear {
            triggerEffectLoop()
        }
        .onDisappear {
            timer?.invalidate()
        }
    }
    
    private func triggerEffectLoop() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: true, block: { _ in
            triggerEffect.toggle()
        })
    }
}

#Preview {
    QrDataCard(qrData: "bla", timeStamp: "16.08.2025")
}
