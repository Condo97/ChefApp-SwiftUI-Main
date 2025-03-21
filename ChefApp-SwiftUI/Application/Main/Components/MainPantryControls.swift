//
//  MainPantryControls.swift
//  ChefApp-SwiftUI
//
//  Created by Alex Coundouriotis on 3/16/25.
//

import SwiftUI

struct MainPantryControls: View {
    
    let showAddPantryItemDirectlyToCameraPopup: () -> Void
    let showPantry: () -> Void
    
    var body: some View {
        HStack {
            // Quick Camera Add To Pantry
            Button(action: {
                HapticHelper.doLightHaptic()
                
                showAddPantryItemDirectlyToCameraPopup()
            }) {
                ZStack {
                    Text(Image(systemName: "camera"))
                        .font(.custom(Constants.FontName.body, fixedSize: 28.0))
                        .foregroundStyle(Colors.foregroundText)
                        .padding(8)
                        .frame(maxHeight: .infinity)
                        .background(RoundedRectangle(cornerRadius: 14.0)
                            .fill(Colors.foreground)
                            .aspectRatio(1, contentMode: .fill))
                    
                    Image(systemName: "plus")
                        .foregroundStyle(Colors.foreground)
                        .fontWeight(.black)
                        .scaleEffect(x: 1.2, y: 1.2)
                        .offset(x: 15, y: 10)
                    
                    Image(systemName: "plus")
                        .foregroundStyle(Colors.elementBackground)
                        .fontWeight(.black)
                        .offset(x: 15, y: 10)
                }
            }
            
            // Show Pantry Button
            Button(action: {
                HapticHelper.doLightHaptic()
                
                showPantry()
            }) {
                ZStack {
                    HStack {
                        Spacer()
                        Text("\(Image(systemName: "list.bullet")) View Pantry")
                            .font(.custom(Constants.FontName.heavy, size: 20.0))
                        Spacer()
                    }
                }
                .foregroundStyle(Colors.foregroundText)
                .padding()
                .background(Colors.foreground)
                .clipShape(RoundedRectangle(cornerRadius: 14.0))
            }
        }
    }
    
}
