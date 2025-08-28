//
//  ScanSettingProvider.swift
//  InventoryManager
//
//  Created by Milan Parađina on 27.08.2025..
//

import Foundation

protocol ScanSettingProvider {
    var showQrCodeScreen: Bool { get }
    var saveDataOnDismiss: Bool { get }
    var saveDataOnError: Bool { get }
}
