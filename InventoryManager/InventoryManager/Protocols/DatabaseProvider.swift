//
//  DatabaseProvider.swift
//  InventoryManager
//
//  Created by Milan Parađina on 27.08.2025..
//

import Foundation

protocol DatabaseProvider {
    func createQrCodeData(with text: String, timestamp: Date)
}
