//
//  TabLabelView.swift
//  InventoryManager
//
//  Created by Milan Parađina on 01.08.2025..
//

import SwiftUI

struct TabLabelView: View {
    var uiImageString: String
    var labelString: String
    var body: some View {
        VStack {
            Image(uiImage: UIImage(systemName: uiImageString)!)
            Text(labelString)
                .font(.caption)
        }
    }
}

#Preview {
    TabLabelView(uiImageString: "gear", labelString: "Settings")
}
