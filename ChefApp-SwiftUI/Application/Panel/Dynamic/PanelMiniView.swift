//
//  PanelMiniView.swift
//  Barback
//
//  Created by Alex Coundouriotis on 9/18/23.
//

import Foundation
import SwiftUI

struct PanelMiniView<S: ShapeStyle & View, T: ShapeStyle>: View {
    
    var panel: Panel
    var textStyle: T
    var background: S
    
    var namespace: Namespace.ID
    
    var body: some View {
        ZStack {
            VStack {
                HStack {
                    Text(panel.emoji)
                        .font(.custom(Constants.FontName.black, fixedSize: 34.0))
                    Spacer()
                }
                
                HStack {
                    Text(panel.title)
                        .font(Font.custom("avenir-black", fixedSize: 17.0))
                        .lineLimit(2)
                        .foregroundStyle(textStyle)
                        .multilineTextAlignment(.leading)
                        .padding(.bottom, 2)
                        .minimumScaleFactor(0.5)
                    Spacer()
                }
                
                HStack {
                    Text(panel.summary)
                        .font(Font.custom("avenir-book", size: 12.0))
                        .foregroundStyle(textStyle)
                        .multilineTextAlignment(.leading)
                        .minimumScaleFactor(0.5)
                    Spacer(minLength: 0)
                }
                Spacer()
            }
        }
        .padding([.leading, .trailing])
        .padding([.top, .bottom], 8)
        .frame(width: 180, height: 140)
    }
    
}

@available(iOS 17, *)
#Preview("Create Panel", traits: .sizeThatFitsLayout) {
    @Previewable @Namespace var namespace
    
    return PanelMiniView(
        panel: Panel(
            emoji: "😊",
            title: "Title",
            summary: "Description",
            prompt: "Prompt",
            components: []),
        textStyle: Colors.foregroundText,
        background: Colors.background,
        namespace: namespace)
}
