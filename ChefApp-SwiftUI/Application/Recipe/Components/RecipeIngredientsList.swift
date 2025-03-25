//
//  RecipeIngredientsList.swift
//  ChefApp-SwiftUI
//
//  Created by Alex Coundouriotis on 3/16/25.
//

import SwiftUI

struct RecipeIngredientsList: View {
    
    @ObservedObject var recipe: Recipe
    let isLoadingRegenerateDirections: Bool
    let shouldRegenerateDirections: () -> Void
    let cardColor: Color
    let ingredientsScrollOffset: Int
    
    @Environment(\.managedObjectContext) private var viewContext
    
    @State private var editingIngredient: RecipeMeasuredIngredient?
    
    @State private var isEditingIngredients: Bool = false
    
    private var recipeEstimatedServings: Binding<Int> {
        Binding(
            get: {
                return Int(recipe.estimatedServingsModified == 0 ? recipe.estimatedServings : recipe.estimatedServingsModified)
            },
            set: { value in
                viewContext.performAndWait {
                    recipe.estimatedServingsModified = Int16(value)
                    
                    do {
                        try viewContext.save()
                    } catch {
                        // TODO: Handle Errors
                        print("Error saving viewContext in RecipeView... \(error)")
                    }
                }
            }
        )
    }
    
    private var measurementAndIngredientOrServingsHasEdits: Bool {
        (recipe.measuredIngredients?.allObjects as? [RecipeMeasuredIngredient])?.contains(where: {
            ($0.nameAndAmountModified != nil && $0.nameAndAmountModified != $0.nameAndAmount) || $0.markedForDeletion
        }) ?? false
        ||
        recipe.estimatedServingsModified != 0 && recipe.estimatedServings != recipe.estimatedServingsModified
    }
    
    var body: some View {
        ZStack {
            // Measured Ingredients
            if let measuredIngredients = recipe.measuredIngredients?.allObjects as? [RecipeMeasuredIngredient], measuredIngredients.count > 0 {
                VStack {
                    ZStack(alignment: .top) {
                        // Insert Ingredient Button
                        HStack {
                            Spacer()
                            
                            Button(action: {
                                HapticHelper.doLightHaptic()
                                
                                withAnimation(.bouncy) {
                                    isEditingIngredients.toggle()
                                }
                            }) {
                                Text(isEditingIngredients ? Image(systemName: "checkmark") : Image(systemName: "square.and.pencil"))
                                    .font(.custom(Constants.FontName.body, size: 20.0))
                                    .foregroundStyle(isEditingIngredients ? Colors.elementText : Colors.elementBackground)
                                    .frame(width: 48.0, height: 48.0)
                                    .background(isEditingIngredients ? Colors.elementBackground : Colors.background)
                                    .clipShape(RoundedRectangle(cornerRadius: 14.0))
                            }
                        }
                        
                        // Edit Servings Picker
                        HStack {
                            VStack(spacing: 2.0) {
                                Text("Servings:")
                                    .font(.custom(Constants.FontName.body, size: 12.0))
                                    .foregroundStyle(Colors.foregroundText)
                                
                                Menu {
                                    Picker(
                                        selection: recipeEstimatedServings,
                                        content: {
                                            ForEach(1..<100) { i in
                                                Text("\(i)")
                                                    .font(.custom(Constants.FontName.body, size: 14.0))
                                                    .tag(i)
                                            }
                                        },
                                        label: {
                                            
                                        })
                                } label: {
                                    HStack {
                                        Text("\(recipeEstimatedServings.wrappedValue)")
                                            .font(.custom(Constants.FontName.body, size: 14.0))
                                        
                                        Image(systemName: "chevron.up.chevron.down")
                                            .imageScale(.medium)
                                        
                                        Spacer()
                                    }
                                    .padding([.leading, .trailing])
                                }
                                .menuOrder(.fixed)
                                .menuIndicator(.visible)
                                .foregroundStyle(Colors.elementBackground)
                                .tint(Colors.elementBackground)
                            }
                            .frame(width: 70.0, height: 48.0)
                            .background(Colors.background)
                            .clipShape(RoundedRectangle(cornerRadius: 14.0))
                            .fixedSize(horizontal: true, vertical: false)
                            
                            Spacer()
                        }
                        
                        // Ingredients Title
                        HStack {
                            Text("Ingredients")
                                .font(.custom(Constants.FontName.black, size: 20.0))
                                .foregroundStyle(Colors.foregroundText)
                        }
                        .padding(.top, 8)
                        .padding(.bottom, 1)
                    }
                    
                    Spacer(minLength: 16.0)
                    
                    VStack(spacing: isEditingIngredients ? 8.0 : 2.0) {
                        ForEach(measuredIngredients) { measuredIngredient in
                            HStack {
                                RecipeEditableIngredientView(
                                    measuredIngredient: measuredIngredient,
                                    isExpanded: $isEditingIngredients,
                                    isDisabled: isLoadingRegenerateDirections,
                                    onEdit: {
                                        editingIngredient = measuredIngredient
                                    })
                                Spacer()
                            }
                        }
                    }
                    //                    .padding([.leading, .trailing])
                    
                    // Add Ingredient Button when editing ingredients
                    if editingIngredient != nil {
                        Button(action: {
                            HapticHelper.doLightHaptic()
                            
                            insertAndEditNewIngredient()
                        }) {
                            HStack {
                                Spacer()
                                Text("\(Image(systemName: "plus")) Add Ingredient")
                                    .font(.custom(Constants.FontName.heavy, size: 17.0))
                                    .foregroundStyle(Colors.elementBackground)
                                Spacer()
                            }
                            .padding(8)
                            .background(Colors.background)
                            .clipShape(RoundedRectangle(cornerRadius: 24.0))
                        }
                        .animation(.bouncy, value: isEditingIngredients)
                    }
                    
                    // Regenerate Directions Button
                    HStack {
                        if measurementAndIngredientOrServingsHasEdits {
                            Button(action: {
                                HapticHelper.doMediumHaptic()
                                
                                shouldRegenerateDirections()
                            }) {
                                ZStack {
                                    if isLoadingRegenerateDirections {
                                        HStack {
                                            Spacer()
                                            ProgressView()
                                                .tint(Colors.elementText)
                                                .padding(.trailing)
                                        }
                                    }
                                    
                                    HStack {
                                        Spacer()
                                        Text("Update Instructions...")
                                            .font(.custom(Constants.FontName.heavy, size: 17.0))
                                            .foregroundStyle(Colors.elementText)
                                        Spacer()
                                    }
                                }
                            }
                            .padding(8)
                            .background(Colors.elementBackground)
                            .clipShape(RoundedRectangle(cornerRadius: 24.0))
                            .opacity(isLoadingRegenerateDirections ? 0.4 : 1.0)
                            .disabled(isLoadingRegenerateDirections)
                            .padding(.top, 8)
                        }
                    }
                }
                .padding()
                .background(cardColor)
                .clipShape(RoundedRectangle(cornerRadius: 24.0))
            } else {
                // No measured ingredients are loaded, so show loading
                VStack {
                    Spacer()
                    Text("Loading Ingredients & Instructions ...")
                        .font(.custom(Constants.FontName.black, size: 20.0))
                    ProgressView()
                        .progressViewStyle(.circular)
                        .controlSize(.large)
                        .tint(Colors.elementBackground)
                    Spacer()
                }
            }
        }
        .clearFullScreenCover(item: $editingIngredient) { editingIngredient in
            ZStack {
                Color.clear
                    .background(Material.thin)
                ZStack {
                    RecipeIngredientEditorView(
                        measuredIngredient: editingIngredient,
                        isShowing: .constant(true))
                    .padding()
                    .background(Material.regular)
                    .clipShape(RoundedRectangle(cornerRadius: 28.0))
                    .padding()
                    .animation(.easeInOut, value: editingIngredient)
                }
                .transition(.move(edge: .bottom))
            }
        }
    }
    
    func insertAndEditNewIngredient() {
        Task {
            // TODO: Is this good enough or does this need a better implementation lol
            let measuredIngredient: RecipeMeasuredIngredient
            do {
                measuredIngredient = try await RecipeMeasuredIngredientCDClient.appendMeasuredIngredient(
                    to: recipe,
                    in: viewContext)
            } catch {
                // TODO: Handle Errors
                print("Error inserting ingredient in RecipeView... \(error)")
                return
            }
            
            await MainActor.run {
                editingIngredient = measuredIngredient
            }
        }
    }
    
}


@available(iOS 17, *)
#Preview {
    
    @Previewable @State var recipe: Recipe?
    
    
    ZStack {
        if let recipe {
            RecipeIngredientsList(
                recipe: recipe,
                isLoadingRegenerateDirections: false,
                shouldRegenerateDirections: {
                    
                },
                cardColor: .background,
                ingredientsScrollOffset: 0)
        }
    }
    .task {
        do {
            recipe = try await CDClient.mainManagedObjectContext.fetch(Recipe.fetchRequest())[0]
        } catch {
            print("Error getting recipe in RecipeIngredientsList preview... \(error)")
        }
    }
    
}
