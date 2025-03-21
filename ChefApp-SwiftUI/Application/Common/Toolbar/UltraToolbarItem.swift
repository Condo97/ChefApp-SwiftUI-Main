//
//  UltraToolbarItem.swift
//  Barback
//
//  Created by Alex Coundouriotis on 10/11/23.
//

import SwiftUI

struct UltraToolbarItem: ToolbarContent {
    
    @State var trailingPadding: CGFloat = -8
    let color: Color
        
    var body: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            UltraButton(
                color: color,
                sparkleDiameter: 19.0,
                fontSize: 14.0,
                cornerRadius: 8.0,
                horizontalSpacing: 2.0,
                innerPadding: 4.0)
//                lineWidth: 1.5)
                .padding(.trailing, trailingPadding)
        }
    }
    
}

#Preview {
    
    ZStack {
        
    }
    .toolbar {
        UltraToolbarItem(color: Colors.elementBackground)
    }
    
}
