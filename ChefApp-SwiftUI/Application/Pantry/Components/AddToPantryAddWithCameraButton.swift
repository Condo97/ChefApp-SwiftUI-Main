//
//  AddToPantryAddWithCameraButton.swift
//  ChefApp-SwiftUI
//
//  Created by Alex Coundouriotis on 3/18/25.
//

import SwiftUI

struct AddToPantryAddWithCameraButton: View {
    
    let onAddWithCamera: () -> Void
    
    var body: some View {
        // Add with Camera Button
        Button(action: onAddWithCamera) {
            ZStack {
                HStack {
                    Spacer()
                    Image(systemName: "chevron.right")
                        .imageScale(.medium)
                }
                HStack {
                    Spacer()
                    Image(systemName: "camera")
                        .font(.body, 20.0)
                    Text("Scan to Add")
                        .font(.custom(Constants.FontName.heavy, size: 20.0))
                    Spacer()
                }
            }
        }
        .padding()
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: 14.0)
                    .stroke(Colors.elementBackground)
                RoundedRectangle(cornerRadius: 14.0)
                    .fill(Colors.foreground)
            }
        )
        .foregroundStyle(Colors.elementBackground)
        .clipShape(RoundedRectangle(cornerRadius: 14.0))
        .padding(.top, 8)
        
        // Add with Camera Description
        HStack {
            Text("Take a picture of your pantry, fridge, receipt items, and more. AI will automatically find and add items.")
                .font(.custom(Constants.FontName.light, size: 14.0))
                .multilineTextAlignment(.center)
                .opacity(0.4)
            Spacer()
        }
        .padding(.horizontal)
    }
    
}
