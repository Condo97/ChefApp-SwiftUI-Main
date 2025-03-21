//
//  RecipeSaveGenerationSwipeView.swift
//  ChefApp-SwiftUI
//
//  Created by Alex Coundouriotis on 12/12/24.
//

import CoreData
import SwiftUI

class RecipeSaveGenerationSwipeViewModel: ObservableObject, Identifiable {
    
    @Published var recipeGenerationSwipeViewModel: RecipeGenerationSwipeViewModel
    
    init(recipeGenerationSwipeViewModel: RecipeGenerationSwipeViewModel) {
        self.recipeGenerationSwipeViewModel = recipeGenerationSwipeViewModel
    }
    
    func handleSwipe(
        recipe: Recipe,
        swipeDirection: RecipeSwipeCardView.SwipeDirection,
        adOrReviewCoordinator: AdOrReviewCoordinator,
        premiumUpdater: PremiumUpdater,
        in managedContext: NSManagedObjectContext
    ) {
        if swipeDirection == .right {
            // Save to Recipes
            Task {
                do {
                    try await RecipeCDClient.updateRecipe(recipe, saved: true, in: managedContext)
                } catch {
                    // TODO: Handle Errors
                    print("Error updating recipe in MainView... \(error)")
                }
            }
            
            // Show ad or review if premium
            Task {
                await adOrReviewCoordinator.showWithCooldown(isPremium: premiumUpdater.isPremium)
            }
        }
    }
    
    func handleDetailViewSave(
        recipe: Recipe,
        adOrReviewCoordinator: AdOrReviewCoordinator,
        premiumUpdater: PremiumUpdater,
        in managedContext: NSManagedObjectContext
    ) {
        // Save to Recipes
        Task {
            do {
                try await RecipeCDClient.updateRecipe(recipe, saved: true, in: managedContext)
            } catch {
                // TODO: Handle Errors
                print("Error updating recipe in MainView... \(error)")
            }
        }
        
        // Show ad or review if premium
        Task {
            await adOrReviewCoordinator.showWithCooldown(isPremium: premiumUpdater.isPremium)
        }
    }
    
    func handleUndo(
        recipe: Recipe,
        previousSwipeDirection: RecipeSwipeCardView.SwipeDirection,
        adOrReviewCoordinator: AdOrReviewCoordinator,
        premiumUpdater: PremiumUpdater,
        in viewContext: NSManagedObjectContext
    ) {
        // Save to Recipes
        Task {
            do {
                try await RecipeCDClient.updateRecipe(recipe, saved: true, in: viewContext)
            } catch {
                // TODO: Handle Errors
                print("Error updating recipe in MainView... \(error)")
            }
        }
        
        // Show ad or review if premium
        Task {
            await adOrReviewCoordinator.showWithCooldown(isPremium: premiumUpdater.isPremium)
        }
    }
    
}

struct RecipeSaveGenerationSwipeView: View {
    
    @ObservedObject var viewModel: RecipeSaveGenerationSwipeViewModel
    let onClose: () -> Void
    
    @Environment(\.requestReview) private var requestReview
    @Environment(\.managedObjectContext) private var viewContext
    
    @EnvironmentObject private var constantsUpdater: ConstantsUpdater
    @EnvironmentObject private var premiumUpdater: PremiumUpdater
    
    @StateObject private var adOrReviewCoordinator = AdOrReviewCoordinator()
    
    var body: some View {
        // Recipe Generation Swipe View
        RecipeGenerationSwipeView(
            viewModel: viewModel.recipeGenerationSwipeViewModel,
            onSwipe: {
                viewModel.handleSwipe(
                    recipe: $0,
                    swipeDirection: $1,
                    adOrReviewCoordinator: adOrReviewCoordinator,
                    premiumUpdater: premiumUpdater,
                    in: viewContext)
            },
            onDetailViewSave: {
                viewModel.handleDetailViewSave(
                    recipe: $0,
                    adOrReviewCoordinator: adOrReviewCoordinator,
                    premiumUpdater: premiumUpdater,
                    in: viewContext)
            },
            onUndo: {
                viewModel.handleUndo(
                    recipe: $0,
                    previousSwipeDirection: $1,
                    adOrReviewCoordinator: adOrReviewCoordinator,
                    premiumUpdater: premiumUpdater,
                    in: viewContext)
            },
            onClose: onClose)
        
        // Interstitial to be shown on generate
        .interstitialInBackground(
            interstitialID: Keys.GAD.Interstitial.mainContainerGenerate,
            disabled: premiumUpdater.isPremium,
            isPresented: $adOrReviewCoordinator.isShowingInterstitial)
        
        // Show ad on appear if not premium
        .task {
            // Show ad or review immediately if premium and not fewer than one launch
            if constantsUpdater.launchCount >= 2 {
                await adOrReviewCoordinator.showAdImmediately(isPremium: premiumUpdater.isPremium)
            }
        }
        
        // Show review on change of requestedReview
        .onReceive(adOrReviewCoordinator.$requestedReview) { newValue in
            if newValue {
                requestReview()
            }
        }
    }
}

//#Preview {
//
//    RecipeSaveGenerationSwipeView()
//    
//}
