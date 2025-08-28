//
//  GoogleSpreadsheetWriter.swift
//  InventoryManager
//
//  Created by Milan Parađina on 27.08.2025..
//

import Foundation

protocol GoogleSpreadsheetWriter {
    func configure() async throws
    func appendDataToSheet(qrCodeData: [String]) async throws
}
