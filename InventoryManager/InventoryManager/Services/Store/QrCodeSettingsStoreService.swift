//
//  QrCodeSettingsStoreService.swift
//  InventoryManager
//
//  Created by Milan Parađina on 22.08.2025..
//

import Foundation
import SwiftUI

final class QrCodeSettingsStoreService: ObservableObject {
    
    @AppStorage(UserDefaultsConstants.qrCodeDelimiter) var qrCodeDelimiter: String?
    @AppStorage(UserDefaultsConstants.acceptQrWithSpecificText) var acceptQrWithSpecificText: Bool?
    @AppStorage(UserDefaultsConstants.qrAcceptanceText) var qrAcceptanceText: String?
    @AppStorage(UserDefaultsConstants.ignoreQrAcceptanceText) var ignoreQrAcceptanceText: Bool?
}
