//
//  QrSettingsProvider.swift
//  InventoryManager
//
//  Created by Milan Parađina on 27.08.2025..
//

protocol QrSettingsProvider {
    var qrCodeDelimiter: String? { get set}
    var qrAcceptanteText: String? { get set }
    var ignoreQrAcceptanceText: Bool? { get set }
    var acceptQrWithSpecificText: Bool? { get set }
}
