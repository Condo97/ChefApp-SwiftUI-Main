//
//  RecipeSwipeView.swift
//  ChefApp-SwiftUI
//
//  Created by Alex Coundouriotis on 12/7/24.
//

import SwiftUI

struct RecipeSwipeView: View {

    var recipeGenerator: RecipeGenerator
    @ObservedObject var recipeSwipeCardsViewModel: RecipeSwipeCardsView.Model
    let isLoading: Bool
    let onSwipe:
        (_ recipe: Recipe, _ swipeDirection: RecipeSwipeCardView.SwipeDirection)
            -> Void
    let onDetailViewSave: (Recipe) -> Void
    let onClose: () -> Void
    

    @Environment(\.managedObjectContext) private var viewContext

    @EnvironmentObject private var premiumUpdater: PremiumUpdater


    @State private var presentingRecipeViewModel: RecipeViewModel?

    @State private var isShowingUltraView: Bool = false

    @State private var swipedCardsIterator: Int = 0  // This is for the tap animation

    var body: some View {
        Group {
            if !(recipeSwipeCardsViewModel.unswipedCards.isEmpty && isLoading) {
                RecipeSwipeCardsView(
                    model: recipeSwipeCardsViewModel,
                    onTap: { card in
                        if let recipe = card.recipe {
                            withAnimation {
                                self.presentingRecipeViewModel = RecipeViewModel(recipe: recipe)
                            }
                        }
                    },
                    onSwipe: { card, direction in
                        // Call onSwipe if recipe can be unwrapped
                        if let recipe = card.recipe {
                            onSwipe(recipe, direction)
                        }
                    },
                    onSwipeComplete: {
                        // Increment swipedCardsIterator
                        DispatchQueue.main.async {
                            self.swipedCardsIterator += 1
                        }
                    },
                    onClose: onClose)
            } else {
                VStack {
                    VStack {
                        Text("Loading Recipes")
                            .font(.heavy, 20.0)
                        ProgressView()

                        if !premiumUpdater.isPremium {
                            Text("Upgrade for Faster Queue")
                                .font(.heavy, 14.0)
                            Button(action: { isShowingUltraView = true }) {
                                Text("Upgrade")
                                    .appButtonStyle()
                            }
                        }
                    }
                    .frame(maxHeight: .infinity)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .background(Colors.background)
        .ultraViewPopover(isPresented: $isShowingUltraView)
        .saveRecipePopup(
            viewModel: $presentingRecipeViewModel,
            didSaveRecipe: { recipe in
                onDetailViewSave(recipe)
                recipeSwipeCardsViewModel.removeTopCard()
            })
    }

}

#Preview {

    let cards =
        (try! CDClient.mainManagedObjectContext.fetch(Recipe.fetchRequest()))
        .map({
            RecipeSwipeCardView.Model(
                recipe: $0,
                imageURL: AppGroupLoader(
                    appGroupIdentifier: Constants.Additional.appGroupID
                ).fileURL(for: $0.imageAppGroupLocation!),
                name: $0.name,
                summary: $0.summary
            )
        })

    var recipeGenerator = RecipeGenerator()

    return RecipeSwipeView(
        recipeGenerator: recipeGenerator,
        recipeSwipeCardsViewModel: RecipeSwipeCardsView.Model(cards: cards),
        isLoading: false,
        onSwipe: { recipe, swipeDirection in

        },
        onDetailViewSave: { recipe in

        },
        onClose: {

        }
    )
    .task {
        let authToken: String
        do {
            authToken = try await AuthHelper.ensure()
        } catch {
            // TODO: [Error Handling] Henlde errors
            print("Error ensuring authToken in RecipeSwipeView... \(error)")
            return
        }
        
        try! await recipeGenerator.create(
            ingredients: "",
            modifiers: "",
            expandIngredientsMagnitude: 0,
            authToken: authToken,
            in: CDClient.mainManagedObjectContext)
        try! await recipeGenerator.create(
            ingredients: "",
            modifiers: "",
            expandIngredientsMagnitude: 0,
            authToken: authToken,
            in: CDClient.mainManagedObjectContext)
        try! await recipeGenerator.create(
            ingredients: "",
            modifiers: "",
            expandIngredientsMagnitude: 0,
            authToken: authToken,
            in: CDClient.mainManagedObjectContext)
        try! await recipeGenerator.create(
            ingredients: "",
            modifiers: "",
            expandIngredientsMagnitude: 0,
            authToken: authToken,
            in: CDClient.mainManagedObjectContext)
        try! await recipeGenerator.create(
            ingredients: "",
            modifiers: "",
            expandIngredientsMagnitude: 0,
            authToken: authToken,
            in: CDClient.mainManagedObjectContext)
    }
    .environment(\.managedObjectContext, CDClient.mainManagedObjectContext)
    .environmentObject(PremiumUpdater())
    .environmentObject(ProductUpdater())
    .environmentObject(RemainingUpdater())
    .environmentObject(ScreenIdleTimerUpdater())

}
