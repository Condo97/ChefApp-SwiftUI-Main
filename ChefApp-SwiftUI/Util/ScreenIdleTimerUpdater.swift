//
//  ScreenIdleTimerUpdater.swift
//  ChefApp-SwiftUI
//
//  Created by Alex Coundouriotis on 12/3/24.
//

import SwiftUI
import Combine

class ScreenIdleTimerUpdater: ObservableObject {
    
    @Published var keepScreenOn: Bool = false {
        didSet {
            UIApplication.shared.isIdleTimerDisabled = keepScreenOn
        }
    }

    init() {
        self.keepScreenOn = UIApplication.shared.isIdleTimerDisabled
    }
    
}
