//
//  QRCodeResult.swift
//  InventoryManager
//
//  Created by Milan Parađina on 03.08.2025..
//

import Foundation

struct QRCodeResult: Identifiable, Equatable {
    let id = UUID()
    let value: [String]
}
