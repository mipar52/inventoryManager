//
//  GoogleAuthError.swift
//  InventoryManager
//
//  Created by Milan Parađina on 02.08.2025..
//

enum GoogleAuthError: Error {
    case NotSignedIn
    case ServiceUnavailable
    case SignInError(error: String?)
}
