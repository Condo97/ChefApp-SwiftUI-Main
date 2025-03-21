//
//  LogoToolbarItem.swift
//  Barback
//
//  Created by Alex Coundouriotis on 10/11/23.
//

import SwiftUI

struct LogoToolbarItem: ToolbarContent {
    
    @State var foregroundColor: Color = Colors.elementText
    
    var body: some ToolbarContent {
        ToolbarItem(placement: .principal) {
            Image(Constants.ImageName.navBarLogoImage)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 140.0)
                .foregroundStyle(foregroundColor)
        }
    }
    
}

#Preview {
    ZStack {
        
    }
    .toolbar {
        LogoToolbarItem()
    }
}
