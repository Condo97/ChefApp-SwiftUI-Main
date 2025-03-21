//
//  View+Header.swift
//  Barback
//
//  Created by Alex Coundouriotis on 10/8/23.
//

import Foundation
import SwiftUI

extension View {
    
    func chefAppHeader<LeftContent: View, RightContent: View>(titleColor: Color = Colors.foreground, backgroundColor: Color = Colors.secondaryBackground, showsDivider: Bool, @ViewBuilder left: ()->LeftContent, @ViewBuilder right: ()->RightContent) -> some View {
        VStack(spacing: 0.0) {
            ZStack {
                HStack {
                    VStack {
                        Spacer()
                        left()
                    }
                    Spacer()
                }
                
                HStack {
                    Spacer()
                    VStack(spacing: 0.0) {
                        Spacer()
                        Image(Constants.ImageName.navBarLogoImage)
                            .resizable()
                            .renderingMode(.template)
                            .aspectRatio(contentMode: .fit)
                            .foregroundStyle(Colors.navigationItemColor)
                            .frame(width: 140.0)
                            .padding(.bottom, 6)
                        if showsDivider {
                            Divider()
                                .tint(Colors.foregroundText)
                        }
                    }
                    Spacer()
                }
                
                HStack {
                    Spacer()
                    VStack {
                        Spacer()
                        right()
                    }
                }
            }
            .frame(height: 100)
            .background(backgroundColor)
            
            self
        }
    }
    
}


#Preview {
    
    ZStack {
        Colors.background
    }
    .chefAppHeader(
        showsDivider: true,
        left: {
        
    },
        right: {
        
    })
    .ignoresSafeArea()
    
}
