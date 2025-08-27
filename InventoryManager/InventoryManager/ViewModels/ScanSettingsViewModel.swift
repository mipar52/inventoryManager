//
//  ScanSettingsViewModel.swift
//  InventoryManager
//
//  Created by Milan Parađina on 25.08.2025..
//

import Foundation

@MainActor
final class ScanSettingsViewModel: ObservableObject {
    let scanSettingsService: ScanSettingsStoreService
    
    @Published var saveDataOnDismiss: Bool {
        didSet {
            scanSettingsService.saveDataOnDismiss = saveDataOnDismiss
        }
    }
    
    @Published var saveDataOnError: Bool {
        didSet {
            scanSettingsService.saveDataOnError = saveDataOnError
        }
    }
    @Published var showQrResultScreen: Bool {
        didSet {
            scanSettingsService.showQrResultScreen = showQrResultScreen
        }
    }
    
    init(scanSettingsService: ScanSettingsStoreService = ScanSettingsStoreService()) {
        self.scanSettingsService = scanSettingsService
        self.saveDataOnDismiss = scanSettingsService.saveDataOnDismiss ?? false
        self.saveDataOnError = scanSettingsService.saveDataOnError ?? true
        self.showQrResultScreen = scanSettingsService.showQrResultScreen ?? true
    }
}
