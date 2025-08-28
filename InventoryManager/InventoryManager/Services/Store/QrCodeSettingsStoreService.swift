//
//  QrCodeSettingsStoreService.swift
//  InventoryManager
//
//  Created by Milan Parađina on 22.08.2025..
//

import Foundation
import SwiftUI

final class QrCodeSettingsStoreService: ObservableObject, QrSettingsProvider {
    var qrCodeDelimiter: String? {
        didSet {
            qrCodeDelimiterUserDefault = qrCodeDelimiter
        }
    }
    
    var qrAcceptanteText: String? {
        didSet {
            qrAcceptanceTextUserDefault = qrAcceptanteText
        }
    }
    
    var ignoreQrAcceptanceText: Bool? {
        didSet {
            ignoreQrAcceptanceTextUserDefault = ignoreQrAcceptanceText
        }
    }
    
    var acceptQrWithSpecificText: Bool? {
        didSet {
            acceptQrWithSpecificTextUserDefault = acceptQrWithSpecificText
        }
    }
    
    init() {
        qrCodeDelimiter = qrCodeDelimiterUserDefault
        qrAcceptanteText = qrAcceptanceTextUserDefault
        ignoreQrAcceptanceText = ignoreQrAcceptanceTextUserDefault
        acceptQrWithSpecificText = acceptQrWithSpecificTextUserDefault
    }
    
    @AppStorage(UserDefaultsConstants.qrCodeDelimiter) private var qrCodeDelimiterUserDefault: String?
    @AppStorage(UserDefaultsConstants.acceptQrWithSpecificText) private var acceptQrWithSpecificTextUserDefault: Bool?
    @AppStorage(UserDefaultsConstants.qrAcceptanceText) private var qrAcceptanceTextUserDefault: String?
    @AppStorage(UserDefaultsConstants.ignoreQrAcceptanceText) private var ignoreQrAcceptanceTextUserDefault: Bool?
}
