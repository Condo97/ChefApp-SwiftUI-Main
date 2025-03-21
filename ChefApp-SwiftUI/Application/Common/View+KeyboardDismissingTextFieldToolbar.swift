//
//  View+KeyboardDismissingTextFieldToolbar.swift
//  Barback
//
//  Created by Alex Coundouriotis on 10/13/23.
//

import Foundation
import SwiftUI

extension View {
    
    func keyboardDismissingTextFieldToolbar(_ dismissButtonText: String, color: Color) -> some View {
        self
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    
                    Button(action: {
                        KeyboardDismisser.dismiss()
                    }) {
                        Text(dismissButtonText)
                            .font(.custom(Constants.FontName.heavy, size: 17.0))
                            .foregroundStyle(color)
                    }
                }
            }
    }
    
}
