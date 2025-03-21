//
//  AppButtonStyle.swift
//  SocialBackup
//
//  Created by Alex Coundouriotis on 10/11/24.
//

import SwiftUI

struct AppButtonStyle: ViewModifier {
    
    var foregroundColor: Color
    var backgroundColor: Color
    
    func body(content: Content) -> some View {
        content
            .font(.custom(Constants.FontName.heavy, size: 17.0))
            .foregroundStyle(foregroundColor)
            .padding()
            .background(backgroundColor)
            .clipShape(RoundedRectangle(cornerRadius: 14.0))
    }
    
}

extension View {
    
    public func appButtonStyle(foregroundColor: Color? = nil, backgroundColor: Color? = nil) -> some View {
        self
            .font(.custom(Constants.FontName.heavy, size: 17.0))
            .foregroundStyle(foregroundColor ?? Colors.elementText)
            .padding()
            .background(backgroundColor ?? Colors.elementBackground)
            .clipShape(Capsule())
    }
    
    public func miniButtonStyle(foregroundColor: Color? = nil, backgroundColor: Color? = nil) -> some View {
        self
            .font(.custom(Constants.FontName.heavy, size: 12.0))
            .foregroundStyle(foregroundColor ?? Colors.elementBackground)
            .padding(8)
            .background(backgroundColor ?? Colors.elementText)
            .clipShape(RoundedRectangle(cornerRadius: 14.0))
    }
    
//    public func tabButtonStyle(isSelected: Bool, namespace: Namespace) -> some View {
//        self
//            .font(.custom(Constants.FontName.body, size: isSelected ? 40.0 : 30.0))
//            .foregroundStyle(isSelected ? Colors.elementTextColor : Colors.elementBackgroundColor)
//            .background(
//                Group {
//                    if isSelected {
//                        Circle()
//                            .fill(Colors.elementBackgroundColor)
//                            .frame(width: 40.0)
//                            .matchedGeometryEffect(id: "activeCircle", in: namespace.wrappedValue)
//                    } else {
//                        Circle()
//                            .fill(Colors.elementTextColor)
//                            .frame(width: 20.0)
//                    }
//                })
//    }
    
}
