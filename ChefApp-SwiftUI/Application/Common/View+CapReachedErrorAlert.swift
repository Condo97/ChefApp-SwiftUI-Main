//
//  View+CapReachedErrorAlert.swift
//  Barback
//
//  Created by Alex Coundouriotis on 10/8/23.
//

import Foundation
import SwiftUI

extension View {
    
    func capReachedErrorAlert(isPresented: Binding<Bool>, isShowingUltraView: Binding<Bool>) -> some View {
        self
            .alert("Out of Recipes", isPresented: isPresented, actions: {
                Button("Close", role: .cancel, action: {
                    
                })
                
                Button("Upgrade", role: nil, action: {
                    withAnimation {
                        isShowingUltraView.wrappedValue = true
                    }
                })
            }) {
                switch Int.random(in: 0..<2) {
                case 0:
                    Text("It takes a lot of resources to generate recipes. Please support the developer and upgrade to keep creating. Bon-Apetit'!")
                default:
                    Text("You are out of recipes for today. Please upgrade to continue creating.")
                }
            }
            .onChange(of: isPresented.wrappedValue) { newValue in
                // If newValue is set to true do a warning haptic
                if newValue {
                    HapticHelper.doWarningHaptic()
                }
            }
    }
    
}
