//
//  ScanSettingsStoreService.swift
//  InventoryManager
//
//  Created by Milan Parađina on 22.08.2025..
//

import Foundation
import SwiftUI

@MainActor
final class ScanSettingsStoreService: ObservableObject {
    @AppStorage(UserDefaultsConstants.saveDataOnDismiss) private var saveDataOnDismiss: Bool?
    @AppStorage(UserDefaultsConstants.saveDataOnError) private var saveDataOnError: Bool?
    @AppStorage(UserDefaultsConstants.showQrResultScreen) private var showQrResultScreen: Bool?
    
    func setSaveDataOnDismiss(_ value: Bool) {
        self.saveDataOnDismiss = value
    }
    
    func setSaveDataOnError(_ value: Bool) {
        self.saveDataOnError = value
    }
    
    func setShowQrResultScreen(_ value: Bool) {
        self.showQrResultScreen = value
    }
}
