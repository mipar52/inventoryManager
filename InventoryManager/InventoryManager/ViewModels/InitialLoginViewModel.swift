//
//  InitialLoginViewModel.swift
//  InventoryManager
//
//  Created by Milan Parađina on 01.08.2025..
//

import Foundation
import SwiftUI
import GoogleSignIn

class InitialLoginViewModel: ObservableObject {
    @Published var shouldNavigateToMainView: Bool = false
    let userDefaults: UserDefaults
    
    init(userDefault: UserDefaults = .standard) {
        self.userDefaults = userDefault
    }
        
    func finishedOnboarding() {
        userDefaults.set(false, forKey: UserDefaultsConstants.isUserFirstTime)
        shouldNavigateToMainView.toggle()
    }
}

