//
//  ScanDetailsPlaceholder.swift
//  InventoryManager
//
//  Created by Milan Parađina on 20.08.2025..
//

import SwiftUI
import CoreData

struct ScanDetailsPlaceholder: View {
    let objectID: NSManagedObjectID
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "doc.text.magnifyingglass").font(.largeTitle)
            Text("Scan detail view").font(.headline)
            Text("ObjectID: \(objectID.uriRepresentation().absoluteString)")
                .font(.caption).foregroundStyle(.secondary)
        }
        .padding()
    }
}

#Preview {
  //  ScanDetailsPlaceholder()
}
