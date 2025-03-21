//
//  RecipeTitleEditorView.swift
//  ChefApp-SwiftUI
//
//  Created by Alex Coundouriotis on 12/3/24.
//

import SwiftUI

struct RecipeTitleEditorView: View {
    
    let recipe: Recipe
    @Binding var isPresented: Bool
    
    @Environment(\.managedObjectContext) private var viewContext
    
    @State private var recipeTitleEditor_newTitle = ""
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Edit Title")
                .font(.heavy, 20.0)
            TextField(recipe.name ?? "Title...", text: $recipeTitleEditor_newTitle)
                .font(.body, 17.0)
                .padding(.vertical, 8)
                .padding(.horizontal)
                .frame(maxWidth: .infinity)
                .background(Colors.foreground)
                .clipShape(RoundedRectangle(cornerRadius: 14.0))
                .padding(.horizontal)
            if let name = recipe.name {
                Text("Original Title: \(name)")
                    .font(.body, 14.0)
                    .opacity(0.6)
            }
            
            HStack {
                Button(action: {
                    isPresented = false
                }) {
                    Text("Cancel")
                        .frame(maxWidth: .infinity)
                        .appButtonStyle(foregroundColor: Colors.elementBackground, backgroundColor: Colors.elementText)
                }
                
                Button(action: {
                    if !recipeTitleEditor_newTitle.isEmpty {
                        Task {
                            do {
                                try await RecipeCDClient.updateRecipe(recipe, name: recipeTitleEditor_newTitle, in: viewContext)
                            } catch {
                                // TODO: Handle Errors
                                print("Error updating recipe title in RecipeView... \(error)")
                            }
                        }
                    }
                    isPresented = false
                }) {
                    Text("Save")
                        .frame(maxWidth: .infinity)
                        .appButtonStyle()
                }
            }
        }
        .padding()
        .background(Colors.background)
        .clipShape(RoundedRectangle(cornerRadius: 14.0))
        .padding()
    }
    
}

extension View {
    
    func recipeTitleEditorPopup(isPresented: Binding<Bool>, recipe: Recipe) -> some View {
        self
            .clearFullScreenCover(isPresented: isPresented) {
                RecipeTitleEditorView(
                    recipe: recipe,
                    isPresented: isPresented)
            }
    }
    
}

//#Preview {
//    
//    RecipeTitleEditorView()
//    
//}
