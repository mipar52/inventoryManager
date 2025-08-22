//
//  QrCodeSettingsStoreService.swift
//  InventoryManager
//
//  Created by Milan Parađina on 22.08.2025..
//

import Foundation
import SwiftUI

final class QrCodeSettingsStoreService: ObservableObject {
    private(set) var defaults: UserDefaults = .standard
    
    @AppStorage(UserDefaultsConstants.qrCodeDelimiter) private(set) var qrCodeDelimiter: String?
    @AppStorage(UserDefaultsConstants.acceptQrWithSpecificText) private(set) var acceptQrWithSpecificText: Bool?
    @AppStorage(UserDefaultsConstants.qrAcceptanceText) private(set) var qrAcceptanceText: String?
    @AppStorage(UserDefaultsConstants.ignoreQrAcceptanceText) private(set) var ignoreQrAcceptanceText: Bool?
    
    func setQrCodeDelimiter(_ delimiter: String?) {
        qrCodeDelimiter = delimiter
    }
    func setAcceptQrWithSpecificText(_ accept: Bool?) {
        acceptQrWithSpecificText = accept
    }
    func setQrAcceptanceText(_ text: String?) {
        qrAcceptanceText = text
    }
}
