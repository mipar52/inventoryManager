//
//  UIScanningError.swift
//  InventoryManager
//
//  Created by Milan Parađina on 27.08.2025..
//

import Foundation

enum UIScanningError: Identifiable, Equatable, Error {
    var id: String { localizedDesction }
    case invalidQrCode(missing: String)
    case generic(message: String)
    var localizedDesction: String {
        switch self {
        case .invalidQrCode(missing: let missing):
            return "Invalid QR code. Missing: \(missing)"
        case .generic(message: let message):
            return message
        }
    }
}
