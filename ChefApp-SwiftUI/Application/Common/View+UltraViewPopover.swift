//
//  View+UltraViewPopover.swift
//  Barback
//
//  Created by Alex Coundouriotis on 10/8/23.
//

import Foundation
import SwiftUI

extension View {
    
    func ultraViewPopover(isPresented: Binding<Bool>) -> some View {
        self
            .fullScreenCover(isPresented: isPresented) {
                UltraView(isShowing: isPresented)
            }
    }
    
}
