//
//  SaveRecipeView.swift
//  Barback
//
//  Created by Alex Coundouriotis on 10/6/23.
//

import Foundation
import SwiftUI

struct SaveRecipeView: View {
    
    var viewModel: RecipeViewModel
//    var namespace: Namespace.ID? = nil
//    var imageAnimationID: String? = nil
//    var nameAnimationID: String? = nil
//    var summaryAnimationID: String? = nil
    let onDismiss: () -> Void
    var didSaveRecipe: () -> Void
    
    
    @Environment(\.managedObjectContext) var viewContext
    
    var body: some View {
        VStack(spacing: 0.0) {
//            header
            
            RecipeView(
                viewModel: viewModel,
                showsCloseButton: false,
//                namespace: namespace,
//                imageAnimationID: imageAnimationID,
//                nameAnimationID: nameAnimationID,
//                summaryAnimationID: summaryAnimationID,
                onDismiss: onDismiss)
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Colors.background, for: .navigationBar)
        .navigationTitle("Save Recipe")
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button(action: {
                    HapticHelper.doLightHaptic()
                    
                    withAnimation {
                        onDismiss()
                    }
                }) {
                    Text("Back")
                        .font(.custom(Constants.FontName.heavy, size: 17.0))
                        .foregroundStyle(Colors.elementBackground)
                }
            }
            
            ToolbarItem(placement: .topBarTrailing) {
                Button(action: {
                    HapticHelper.doLightHaptic()
                    
                    Task {
                        await setAsSaved()
                    }
                    
                    didSaveRecipe()
                }) {
                    Text("Save")
                        .font(.custom(Constants.FontName.heavy, size: 17.0))
                        .foregroundStyle(Colors.elementBackground)
                }
            }
        }
    }
    
    func setAsSaved() async {
        do {
            try await RecipeCDClient.updateRecipe(viewModel.recipe, saved: true, in: viewContext)
        } catch {
            // TODO: Handle errors
            print("Error updating recipe to be saved in SaveRecipeView... \(error)")
        }
    }
    
}

extension View {
    
    func saveRecipePopup(viewModel: Binding<RecipeViewModel?>, didSaveRecipe: @escaping (Recipe) -> Void) -> some View {
        self
            .popover(item: viewModel) { unwrappedViewModel in
                // The approach with this one is that the onDismiss is not sent directly to the caller but instead just dismissed and didSaveRecipe still is sent but also with the recipe and the view is dismissed also
                NavigationStack {
                    SaveRecipeView(
                        viewModel: unwrappedViewModel,
                        onDismiss: {
                            viewModel.wrappedValue = nil
                        },
                        didSaveRecipe: {
                            viewModel.wrappedValue = nil
                            didSaveRecipe(unwrappedViewModel.recipe)
                        })
                }
            }
    }
    
    func saveRecipePopup(isPresented: Binding<Bool>, viewModel: RecipeViewModel, recipe: Recipe, didSaveRecipe: @escaping () -> Void) -> some View {
        self
            .popover(isPresented: isPresented) {
                NavigationStack {
                    SaveRecipeView(
                        viewModel: viewModel,
                        onDismiss: { isPresented.wrappedValue = false },
                        didSaveRecipe: didSaveRecipe)
                }
            }
    }
    
}

#Preview {
    var recipe: Recipe {
        let viewContext = PersistenceController.shared.container.viewContext
        
        var recipe = Recipe(entity: Recipe.entity(), insertInto: viewContext)
        recipe.input = "Drink input"
        recipe.name = "Sparkling Mint Vodka"
        recipe.summary = "A refreshing and minty cocktail with a hint of vodka and a sparkling twist!"
        recipe.imageData = Data(referencing: NSData(base64Encoded: "iVBORw0KGgoAAAANSUhEUgAAAFQAAACcCAYAAADh0IwYAAAACXBIWXMAACE3AAAhNwEzWJ96AAAEAElEQVR4nO2d23HbMBBFL91AnA7iDtJBWkkpLiUlpASkA7kDuILIFWw+FNqU+MAucC0OyXtmNMMH5IHP7JLLhWR3AH4C+AZBoQOQAPxYeR574eUBF6GCw/lh7RnsjJMilIsilEx6MLO09iz2RGdm6LrO1p7IHjCzrk/5P6vOZB+8AUAv9LziRPbCCfgQelpxInvhDChCmShCyShCyZyA/2UTAJVO7TyZWR4KPQP4su6ctouZdcBHygO6jrbw2m8Mheo6Wk/uNxShHHK/oQjlkPsNRSiH3G8oQjnkfuO9bAJUizbwZGYZGAtVLVpBX4MC1ykP6Dpaw8tw51aorqNxrpwpQtvJwx1FaDt5uKMIbScPd7Qu304e7lyVTYBq0Qrea1BAQpsZ1qDAdMprjd7P6+0BXUPbyLcHpoTqTu9nVGZOCVUt6mcUfFNC8+fPY79IaBvp9oBSnsyoDgVUiwb4amZXASihDdwW9cB8HarivsyoqAdU2LeQpw7OCZ0cLMpIaD1p6qBSnsyc0HTPSWyUyZ6HIrSeyQcgXUPJTBb2gIr7ElNFPaCUp7Mk9GXh3NGZfEoCloWq6zRPnjuhlCezJDTdaxIbZHbdTRFax+zlUELJKOXrUMqTUcrfi9lHT0CPnwuMFud6JLSCued4QClPpyRUz/NjFp2UhOp5fsyiE6U8mZLQfI9JbIy8dFJC4+Slk0p5MhJKpiQ03WMSGyMtnVSEkpFQMirs4+Slk4vNEUANkluWGiOAUp6OhJLxCJ39lMQBKXbfPEJz+zx2Q/EmrZQnI6FkPEL1de8PUmmAR6iK+wBKeTISSkZlU4xUGiChZJTyZCSUjFI+RrEmL/ZDAfVEe0q9UEApT0dCyUioH1df2CtUf9TFeXNWhJKRUDIS6sfVxvQKVZPZ6cArVE1mJ0p5MhJKRinvJ3kG6aZERilPRkLJSKif7BnkbTA/AvjbOKFN42kuA06hgLr2XqFKeTISSkZCfbgb7BGh6to7UISSkVAyEuojewdGhLp/6A7J3oESSkYpT0ZCyUioD3eDPSL0yF179xJQRKjWlRwo5clIqI9PSfnDYmbu+4e7Yw8ct2vv7dYDilA6EkpGQsuE/uZKVOhbcPweyJHBUaFHflpyoZQnI6FkJLRM6DIXFXrEBknod9ZNiYxSnoyEkpHQMikyOCo0B8cfDgklo5QnI6FlcmSwhBYwsxwZH10COdy3QSLLH0BQKHC8daWoUKU8GQldJvxPDmuEHmkZJNxdqxGaKt6zVXL0DTVCf1e8Z6v8Cr/DzMIvXKLUdv76XeWmUugjLs3mtX/pz3olAI93EzoQ+4zLhXttAaxXBvDc4iRc2E/Rdd13XKJ2y5wjn7Kb4x8K3rA2wlbxlAAAAABJRU5ErkJggg==")!)
        recipe.recipeID = 0
        
        var mi1 = RecipeMeasuredIngredient(entity: RecipeMeasuredIngredient.entity(), insertInto: viewContext)
        mi1.nameAndAmount = "ingredient and measurement"
        mi1.recipe = recipe
        
        var mi2 = RecipeMeasuredIngredient(entity: RecipeMeasuredIngredient.entity(), insertInto: viewContext)
        mi2.nameAndAmount = "2 1/4 cup another ingredient"
        mi2.recipe = recipe
        
        var rd1 = RecipeDirection(entity: RecipeDirection.entity(), insertInto: viewContext)
        rd1.index = 1
        rd1.string = "First direction"
        rd1.recipe = recipe
        
        var rd2 = RecipeDirection(entity: RecipeDirection.entity(), insertInto: viewContext)
        rd2.index = 2
        rd2.string = "Second direction"
        rd2.recipe = recipe
        
        var rd3 = RecipeDirection(entity: RecipeDirection.entity(), insertInto: viewContext)
        rd3.index = 3
        rd3.string = "Third direction"
        rd3.recipe = recipe
        
        var rd4 = RecipeDirection(entity: RecipeDirection.entity(), insertInto: viewContext)
        rd4.index = 4
        rd4.string = "Fourth direction"
        rd4.recipe = recipe
        
        var rd5 = RecipeDirection(entity: RecipeDirection.entity(), insertInto: viewContext)
        rd5.index = 5
        rd5.string = "Fifth direction"
        rd5.recipe = recipe
        
        var rd6 = RecipeDirection(entity: RecipeDirection.entity(), insertInto: viewContext)
        rd6.index = 6
        rd6.string = "Sixth direction"
        rd6.recipe = recipe
        
        var rd7 = RecipeDirection(entity: RecipeDirection.entity(), insertInto: viewContext)
        rd7.index = 7
        rd7.string = "Seventh direction"
        rd7.recipe = recipe
        
        var rd8 = RecipeDirection(entity: RecipeDirection.entity(), insertInto: viewContext)
        rd8.index = 8
        rd8.string = "Eighth direction"
        rd8.recipe = recipe
        
        // TODO: Test images
        
//        var glassGradientColor1 = GlassGradientColor(entity: GlassGradientColor.entity(), insertInto: viewContext)
//        glassGradientColor1.index = 1
//        glassGradientColor1.hexadecimal = "20B2AA"
//        glassGradientColor1.drink = drink
//        
//        var glassGradientColor2 = GlassGradientColor(entity: GlassGradientColor.entity(), insertInto: viewContext)
//        glassGradientColor2.index = 2
//        glassGradientColor2.hexadecimal = "FFFFFF"
//        glassGradientColor2.drink = drink
        
//        var glassGradientColor3 = GlassGradientColor(entity: GlassGradientColor.entity(), insertInto: viewContext)
//        glassGradientColor3.index = 3
//        glassGradientColor3.hexadecimal = "808080"
//        glassGradientColor3.drink = drink
        
        try! viewContext.save()
        
        return recipe
    }
    
    return SaveRecipeView(
        viewModel: RecipeViewModel(recipe: recipe),
        onDismiss: {
            
        },
        didSaveRecipe: {
            
        })
    .environmentObject(PremiumUpdater())
    .environmentObject(ProductUpdater())
    .environmentObject(RemainingUpdater())
}
