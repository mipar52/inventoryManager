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
                        .frame(width: 40, height: 40)
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
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
        )
    }
}

#Preview {
    ZStack {
        Color(.systemGroupedBackground)
            .ignoresSafeArea()
        
        GoogleUserView(
            userImage: UIImage(systemName: "person.circle")!,
            userName: "Google User", isSignedIn: false)
        .padding()
    }
}
