//
//  QrCodeSettingsViewModel.swift
//  InventoryManager
//
//  Created by Milan Parađina on 22.08.2025..
//

import Foundation

@MainActor
final class QrCodeSettingsViewModel: ObservableObject {
    private var qrCodeSettingsService: QrSettingsProvider

    @Published var qrCodeDelimiter: String {
        didSet {
            qrCodeSettingsService.qrCodeDelimiter = qrCodeDelimiter
        }
    }
    @Published var qrAcceptanceText: String {
        didSet {
            qrCodeSettingsService.qrAcceptanteText = qrAcceptanceText
        }
    }
    @Published var acceptQrWithSpecificText: Bool {
        didSet {
            qrCodeSettingsService.acceptQrWithSpecificText = acceptQrWithSpecificText
        }
    }
    @Published var ignoreQrAcceptanceText: Bool {
        didSet {
            qrCodeSettingsService.ignoreQrAcceptanceText = ignoreQrAcceptanceText
        }
    }
        
    
    init(qrCodeSettingsService: QrCodeSettingsStoreService = QrCodeSettingsStoreService()) {
        self.qrCodeSettingsService = qrCodeSettingsService
        self.qrCodeDelimiter = qrCodeSettingsService.qrCodeDelimiter ?? String()
        self.qrAcceptanceText = qrCodeSettingsService.qrAcceptanteText ?? String()
        self.acceptQrWithSpecificText = qrCodeSettingsService.acceptQrWithSpecificText ?? false
        self.ignoreQrAcceptanceText = qrCodeSettingsService.ignoreQrAcceptanceText ?? false
    }
}
