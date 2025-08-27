//
//  ScanSettingsStoreService.swift
//  InventoryManager
//
//  Created by Milan Parađina on 22.08.2025..
//

import Foundation
import SwiftUI

class ScanSettingsStoreService: ObservableObject {
    @AppStorage(UserDefaultsConstants.saveDataOnDismiss) var saveDataOnDismiss: Bool?
    @AppStorage(UserDefaultsConstants.saveDataOnError) var saveDataOnError: Bool?
    @AppStorage(UserDefaultsConstants.showQrResultScreen) var showQrResultScreen: Bool?
}
