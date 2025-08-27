//
//  QrSettingsProvider.swift
//  InventoryManager
//
//  Created by Milan Parađina on 27.08.2025..
//

protocol QrSettingsProvider {
    var qrCodeDelimiter: String? { get }
    var qrAcceptanteText: String? { get }
    var ignoreQrAcceptanceText: Bool { get }
}
