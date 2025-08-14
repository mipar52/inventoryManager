//
//  GoogleUserView.swift
//  InventoryManager
//
//  Created by Milan Parađina on 01.08.2025..
//

import SwiftUI

struct GoogleUserView: View {
    let userImage: UIImage?
    let userName: String
    let isSignedIn: Bool

    var body: some View {
        Group {
            if isSignedIn {
                HStack(spacing: 12) {
                    Image(uiImage: userImage ?? UIImage(systemName: "person.circle")!)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 40, height: 40, alignment: .leading)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color.gray.opacity(0.3), lineWidth: 1))

                    Text(userName)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.primary)

                    Spacer()
                }
            } else {
                HStack {
                    Spacer()
                    Text(userName)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.secondary)
                    Spacer()
                }
            }
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
    ZStack {
        Color(.systemGroupedBackground)
            .ignoresSafeArea()
        
        GoogleUserView(
            userImage: nil,
            userName: "Google User", isSignedIn: true)
        .padding()
    }
}
