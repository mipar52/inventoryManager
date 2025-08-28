//
//  ScanSettingsStoreService.swift
//  InventoryManager
//
//  Created by Milan Parađina on 22.08.2025..
//

import Foundation
import SwiftUI

class ScanSettingsStoreService: ObservableObject, ScanSettingProvider {
    var showQrCodeScreen: Bool {
        get {
            showQrCodeScreenDefault ?? true
        }
        
        set {
            showQrCodeScreenDefault = newValue
        }
    }
    
    var saveDataOnDismiss: Bool {
        get {
            saveDataOnDismissUserDefault ?? false
        }
        
        set {
            saveDataOnDismissUserDefault = newValue
        }
    }
    var saveDataOnError: Bool {
        get {
            saveDataOnErrorUserDefault ?? true
        }
        set {
            saveDataOnErrorUserDefault = newValue
        }
    }
    
    @AppStorage(UserDefaultsConstants.saveDataOnDismiss)  private var saveDataOnDismissUserDefault: Bool?
    @AppStorage(UserDefaultsConstants.saveDataOnError)    private var saveDataOnErrorUserDefault: Bool?
    @AppStorage(UserDefaultsConstants.showQrResultScreen) private var showQrCodeScreenDefault: Bool?
}
