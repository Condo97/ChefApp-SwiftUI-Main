//
//  RecipeGenerationSwipeEntryMini.swift
//  ChefApp-SwiftUI
//
//  Created by Alex Coundouriotis on 3/25/25.
//

import SwiftUI

struct RecipeGenerationSwipeEntryMini: View {
    
    @ObservedObject var viewModel: RecipeGenerationSwipeViewModel
    
    @Environment(\.managedObjectContext) private var viewContext
    
    var body: some View {
        HStack {
            Spacer()
            
            VStack {
                if !viewModel.pantryItems.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            ForEach(viewModel.pantryItems) { pantryItem in
                                if let name = pantryItem.name {
                                    Text(name)
                                        .font(.custom(Constants.FontName.body, size: 12.0))
                                        .padding(.horizontal, 4)
                                        .padding(.vertical, 2)
                                        .background(Colors.background)
                                        .clipShape(Capsule())
                                }
                            }
                        }
                    }
                } else {
                    if let allPantryItems = viewModel.getAllPantryItems(in: viewContext), !allPantryItems.isEmpty {
                        Text("Using all ingredients")
                            .font(.custom(Constants.FontName.heavy, size: 12.0))
                    } else {
                        Text("Using Demo Ingredients")
                            .font(.heavy, 12)
                    }
                }
                
                Group {
                    if viewModel.input.isEmpty {
                        Text("*Tap to Add Prompt*")
                            .opacity(0.6)
                    } else {
                        Text(viewModel.input)
                    }
                }
                .font(.custom(Constants.FontName.body, size: 14.0))
                
                if viewModel.suggestions.count > 0 {
                    Text(viewModel.suggestions.joined(separator: ", "))
                        .font(.custom(Constants.FontName.heavy, size: 10.0))
                }
            }
            
            Spacer()
            
            Image(systemName: "chevron.up")
        }
        .padding()
        .foregroundStyle(Colors.foregroundText)
        .frame(maxWidth: .infinity)
        .background(Colors.foreground)
        .clipShape(RoundedRectangle(cornerRadius: 14.0))
        .padding(.horizontal)
    }
    
}
