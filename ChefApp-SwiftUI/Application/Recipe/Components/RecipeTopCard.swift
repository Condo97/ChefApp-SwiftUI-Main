//
//  RecipeTopCard.swift
//  ChefApp-SwiftUI
//
//  Created by Alex Coundouriotis on 3/16/25.
//

import SwiftUI

struct RecipeTopCard: View {
    
    @ObservedObject var recipe: Recipe
    var toggleRecipeImagePicker: () -> Void
    var toggleEditingTitle: () -> Void
    
    @Environment(\.managedObjectContext) private var viewContext
    
    var body: some View {
        VStack {
            HStack {
                Spacer()
                
                // Top card
                if let name = recipe.name, let summary = recipe.summary {
                    // All necessary components in top card are loaded, so show top card
                    // Top image
                    VStack {
                        if let image = recipe.imageFromAppData {
                            Button(action: toggleRecipeImagePicker) {
                                Image(uiImage: image) // TODO: Resize and set image here and stuff
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .clipShape(RoundedRectangle(cornerRadius: 28.0))
                                    .frame(height: 180.0)
                            }
                        }
                        
                        // Name
                        Text(name)
                            .font(.custom(Constants.FontName.black, size: 24.0))
                            .multilineTextAlignment(.center)
                            .contextMenu {
                                Button("Edit", systemImage: "square.and.pencil", action: toggleEditingTitle)
                            }
                        
                        // Summary
                        Text(summary)
                            .font(.custom(Constants.FontName.body, size: 14.0))
                            .multilineTextAlignment(.center)
                        
                        VStack(spacing: 0.0) {
                            if let url = RecipeShareURLMaker.getShareURL(recipeID: Int(recipe.recipeID)) {
                                HStack {
                                    ShareLink(item: url) {
                                        HStack {
                                            Text("Share Recipe")
                                                .font(.heavy, 17.0)
                                            Image(systemName: "square.and.arrow.up")
                                                .font(.body, 17.0)
                                        }
                                        .foregroundStyle(Colors.elementBackground)
                                        .padding(.vertical, 8)
                                        .padding(.horizontal)
                                        .background(Colors.foreground)
                                        .clipShape(RoundedRectangle(cornerRadius: 14.0))
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }
                        
                        // Calories and Total Time
                        HStack {
                            Spacer()
                            
                            if recipe.estimatedTotalCalories > 0 {
                                // Calories
                                HStack {
                                    Text("Calories:")
                                        .font(.custom(Constants.FontName.black, size: 14.0))
                                        .foregroundStyle(Colors.foregroundText)
                                    
                                    Text("\(recipe.estimatedTotalCalories)")
                                        .font(.custom(Constants.FontName.black, size: 14.0))
                                        .foregroundStyle(Colors.foregroundText)
                                }
                                
                                Spacer()
                            }
                            
                            if recipe.estimatedTotalMinutes > 0 {
                                // Total Time
                                HStack {
                                    Text("Total Time:")
                                        .font(.custom(Constants.FontName.black, size: 14.0))
                                        .foregroundStyle(Colors.foregroundText)
                                    
                                    Text("\(recipe.estimatedTotalMinutes)m")
                                        .font(.custom(Constants.FontName.black, size: 14.0))
                                        .foregroundStyle(Colors.foregroundText)
                                }
                                
                                Spacer()
                            }
                            
                            HStack {
                                Button(action: {
                                    HapticHelper.doLightHaptic()
                                    Task {
                                        let authToken: String
                                        do {
                                            authToken = try await AuthHelper.ensure()
                                        } catch {
                                            // TODO: Handle Errors
                                            print("Error ensuring authToken in RecipeView... \(error)")
                                            return
                                        }
                                        
                                        // TODO: This logic needs to be fixed in the client code here and in other ChefApp apps, if the user switches from like to dislike it needs to both remove one from dislike and add one to like and the other way too
                                        do {
                                            try await ChefAppNetworkService.addOrRemoveLikeOrDislike(request: AddOrRemoveLikeOrDislikeRequest(
                                                authToken: authToken,
                                                recipeID: Int(recipe.recipeID),
                                                shouldAdd: RecipeLikeState(rawValue: Int(recipe.likeState)) != .like, // Add like if not like, otherwise remove
                                                isLike: true))
                                        } catch {
                                            // TODO: Handle Errors
                                            print("Error adding or removing dislike from Recipe on server in RecipeView... \(error)")
                                        }
                                        
                                        do {
                                            try await RecipeCDClient.updateRecipe(recipe, likeState: RecipeLikeState(rawValue: Int(recipe.likeState)) == .like ? .none : .like, in: viewContext)
                                        } catch {
                                            // TODO: Handle Errors
                                            print("Error updating Recipe likeState in RecipeView... \(error)")
                                        }
                                    }
                                }) {
                                    Image(systemName: RecipeLikeState(rawValue: Int(recipe.likeState)) == .like ? "hand.thumbsup.fill" : "hand.thumbsup")
                                        .foregroundStyle(RecipeLikeState(rawValue: Int(recipe.likeState)) == .like ? Colors.elementBackground : Colors.foregroundText)
                                }
                                
                                Button(action: {
                                    HapticHelper.doLightHaptic()
                                    Task {
                                        let authToken: String
                                        do {
                                            authToken = try await AuthHelper.ensure()
                                        } catch {
                                            // TODO: Handle Errors
                                            print("Error ensuring authToken in RecipeView... \(error)")
                                            return
                                        }
                                        
                                        do {
                                            try await ChefAppNetworkService.addOrRemoveLikeOrDislike(request: AddOrRemoveLikeOrDislikeRequest(
                                                authToken: authToken,
                                                recipeID: Int(recipe.recipeID),
                                                shouldAdd: RecipeLikeState(rawValue: Int(recipe.likeState)) != .dislike, // Add dislike if not dislike, otherwise remove
                                                isLike: false))
                                        } catch {
                                            // TODO: Handle Errors
                                            print("Error adding or removing dislike from Recipe on server in RecipeView... \(error)")
                                        }
                                        
                                        do {
                                            try await RecipeCDClient.updateRecipe(recipe, likeState: RecipeLikeState(rawValue: Int(recipe.likeState)) == .dislike ? .none : .dislike, in: viewContext)
                                        } catch {
                                            // TODO: Handle Errors
                                            print("Error updating Recipe likeState in RecipeView... \(error)")
                                        }
                                    }
                                }) {
                                    Image(systemName: RecipeLikeState(rawValue: Int(recipe.likeState)) == .dislike ? "hand.thumbsdown.fill" : "hand.thumbsdown")
                                        .foregroundStyle(RecipeLikeState(rawValue: Int(recipe.likeState)) == .dislike ? Colors.elementBackground : Colors.foregroundText)
                                }
                            }
                            .padding(.trailing)
                        }
                        .padding(.top, 8)
                        
                    }
                } else {
                    // No components in top card are loaded, so show loading
                    VStack {
                        Spacer()
                        Text("Crafting Recipe...")
                            .font(.custom(Constants.FontName.black, size: 32.0))
                        ProgressView()
                            .progressViewStyle(.circular)
                            .controlSize(.large)
                            .tint(Colors.elementBackground)
                        Spacer()
                    }
                }
                
                Spacer()
            }
            Divider()
                .foregroundStyle(Colors.elementBackground)
        }
    }
    
}
