//
//  MainEasyPantryUpdateButton.swift
//  ChefApp-SwiftUI
//
//  Created by Alex Coundouriotis on 3/16/25.
//

import SwiftUI

struct MainEasyPantryUpdateButton: View {
    
    let showEasyPantryUpdateContainer: () -> Void
    
    var body: some View {
        Button(action: showEasyPantryUpdateContainer) {
            HStack {
                Image(systemName: "exclamationmark")
                    .foregroundStyle(Colors.elementBackground)
                    .font(.custom(Constants.FontName.heavy, size: 17.0))
                    .padding(.horizontal)
                
                VStack(alignment: .leading) {
                    Text("Update Pantry")
                        .font(.custom(Constants.FontName.heavy, size: 17.0))
                    Text("Easily remove old items...")
                        .font(.custom(Constants.FontName.body, size: 14.0))
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
            }
            .foregroundStyle(Colors.foregroundText)
            .padding()
            .background(Colors.foreground)
            .clipShape(RoundedRectangle(cornerRadius: 14.0))
        }
        .padding(.vertical, 8)
        .padding(.horizontal)
    }
    
}
