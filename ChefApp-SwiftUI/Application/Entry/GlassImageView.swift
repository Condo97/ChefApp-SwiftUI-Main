//
//  GlassImageView.swift
//  Barback
//
//  Created by Alex Coundouriotis on 9/21/23.
//

import Foundation
import SwiftUI

struct GlassImageView: View {
    
    var drinkColors: [Color]?
    var image: Image
    var height: CGFloat
    var cornerRadius: CGFloat = 24.0
    
    var body: some View {
        
            ZStack {
                RoundedRectangle(cornerRadius: cornerRadius)
                    .aspectRatio(contentMode: .fill)
                    .foregroundStyle(LinearGradient(colors: drinkColors ?? [.black, .black], startPoint: .bottom, endPoint: .top))
                    .scaledToFit()
                image
                    .resizable()
                    .renderingMode(.template)
                    .aspectRatio(contentMode: .fit)
                    .frame(height: height * 0.60)
                    .foregroundStyle(Colors.foreground)
            }
            .frame(height: height)
            .frame(minHeight: 0)
        
    }
    
}
