//
//  View+Fonts.swift
//  MealPlanChef
//
//  Created by Alex Coundouriotis on 12/1/24.
//

import SwiftUI

extension View {
    
    func font(_ fontWeight: FontWeight, _ size: CGFloat) -> some View {
        self
            .font(.custom(fontWeight.appFontName, size: size))
    }
    
}
