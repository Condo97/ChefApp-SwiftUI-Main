//
//  RecipesView.swift
//  ChefApp-SwiftUI
//
//  Created by Alex Coundouriotis on 12/12/24.
//

import SwiftUI

struct RecipesView: View {
    
    let onSelect: (_ recipe: Recipe) -> Void
    
    @Environment(\.managedObjectContext) private var viewContext
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Recipe.creationDate, ascending: false)],
        predicate: NSPredicate(format: "%K = %d", #keyPath(Recipe.saved), true),
        animation: .default
    ) private var recipes: FetchedResults<Recipe>
    
    @State private var recipeToDelete: Recipe?
    
    @State private var alertShowingRecipeToDelete: Bool = false
    
    var body: some View {
        LazyVStack {
            if recipes.isEmpty {
                HStack {
                    Spacer()
                    Text("Tap \"Create Recipe\" below to craft & save your first recipe.")
                        .font(.custom(Constants.FontName.body, size: 17.0))
                        .multilineTextAlignment(.center)
                    Spacer()
                }
                .padding()
                .background(Colors.foreground)
                .clipShape(RoundedRectangle(cornerRadius: 20.0))
            }
            ForEach(recipes) { recipe in
                Button(action: {
                    HapticHelper.doLightHaptic()
                    
                    onSelect(recipe)
                }) {
                    ZStack {
                        RecipeMiniView(
                            viewModel: RecipeMiniViewModel(
                                title: recipe.name ?? "unnamed",
                                summary: recipe.summary,
                                image: recipe.imageFromAppData,
                                date: recipe.updateDate ?? Date.distantPast,
                                isFromTikTok: recipe.sourceTikTokVideoID != nil))
                            .tint(Colors.foregroundText)
                            .padding()
                            .background(Colors.foreground)
                            .clipShape(RoundedRectangle(cornerRadius: 28.0))
                            .padding(.trailing, 8)
                        
                        HStack {
                            Spacer()
                            Image(systemName: "chevron.right")
                                .imageScale(.medium)
                                .foregroundStyle(Colors.foregroundText)
                                .padding(.trailing)
                        }
                    }
                    .padding(.bottom, 2)
                }
                .contextMenu {
                    Button("Delete", systemImage: "trash", role: .destructive) {
                        // Set recipeToDelete and show alert with a boolean state rather than a computed binding to ensure recipeToDelete is not set to nil before it can be deleted
                        recipeToDelete = recipe
                        alertShowingRecipeToDelete = true
                    }
                }
            }
        }
        .padding(.horizontal)
        .alert("Delete Recipe", isPresented: $alertShowingRecipeToDelete, actions: {
            Button("Delete", role: .destructive) {
                Task {
                    if let recipeToDelete {
                        do {
                            try await CDClient.delete(recipeToDelete, in: viewContext)
                        } catch {
                            // TODO: Handle Errors
                            print("Error deleting recipe in MainView... \(error)")
                        }
                    }
                    
                    recipeToDelete = nil
                }
            }
            Button("Cancel", role: .cancel) {
                
            }
        }) {
            Text("Are you sure you want to delete this recipe?")
        }
    }
}

#Preview {
    
    RecipesView(onSelect: { recipe in
        
    })
    .environment(\.managedObjectContext, CDClient.mainManagedObjectContext)
    
}
