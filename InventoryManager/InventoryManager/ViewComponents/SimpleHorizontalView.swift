//
//  SimpleHorizontalView.swift
//  InventoryManager
//
//  Created by Milan Parađina on 01.08.2025..
//

import SwiftUI

struct SimpleHorizontalView: View {
    var labelText: String
    var uiImageText: String
    
    @State var makeItBounce = false
    @State private var bounceTimer: Timer?

    var body: some View {
        HStack {
            Text(labelText)
                .fontWeight(.bold)
            
            Image(systemName: uiImageText)
                .symbolEffect(.bounce.up, value: makeItBounce)
                .foregroundStyle(.white)
        }
        .onAppear {
            makeItBounceLoop()
        }
        .onDisappear {
            bounceTimer?.invalidate()
        }
        .foregroundStyle(.white)
       
    }
    
    private func makeItBounceLoop() {
        bounceTimer?.invalidate()
        bounceTimer = Timer.scheduledTimer(withTimeInterval: 2, repeats: true, block: { _ in
            makeItBounce.toggle()
        })
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        SimpleHorizontalView(labelText: "Skip", uiImageText: "arrow.right.circle")
    }
}
