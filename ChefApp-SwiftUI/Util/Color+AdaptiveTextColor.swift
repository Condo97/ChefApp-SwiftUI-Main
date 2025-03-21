//
//  Color+AdaptiveTextColor.swift
//  Barback
//
//  Created by Alex Coundouriotis on 10/5/23.
//

import Foundation
import SwiftUI

extension Color {
    
    func adaptiveTextColor() -> Color {
            // Compute the color perceived brightness
            let baseColor = UIColor(self)
            guard let rgb = baseColor.cgColor.components else { return .black }
            let perceivedBrightness = (0.299 * rgb[0] + 0.587 * rgb[1] + 0.114 * rgb[2])

            // Return white for dark colors and black for light colors
            return perceivedBrightness > 0.5 ? Color.black : Color.white
        }
    
}
