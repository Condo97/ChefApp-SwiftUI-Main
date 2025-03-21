//
//  RecipeOfTheDayContainer.swift
//  ChefApp-SwiftUI
//
//  Created by Alex Coundouriotis on 11/29/24.
//

import SwiftUI

struct RecipeOfTheDayContainer: View {
    
    let onSelect: (_ recipe: Recipe) -> Void
    let onOpenAddToPantry: () -> Void
    
    // How should this work? It should check for a Recipe that is dailyRecipe and when it was created, and if it is within the day show it and if it is before the day delete it and if there is not a dailyRecipe with creation date within the timeframe generate a new one
    // This loads breakfast, lunch, dinner if not there that day. It auto-scrolls to the current timeframe once loaded or if they are alrady loaded
    
    private let width: CGFloat = 300.0
    private let height: CGFloat = 280.0
    
    @Environment(\.managedObjectContext) private var viewContext
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \PantryItem.updateDate, ascending: false)],
        animation: .default)
    private var pantryItems: FetchedResults<PantryItem>
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Recipe.creationDate, ascending: false)],
        predicate: NSPredicate(format: "%K = %d", #keyPath(Recipe.dailyRecipe_isDailyRecipe), true),
        animation: .default)
    private var dailyRecipes: FetchedResults<Recipe>
    
    @StateObject private var recipeOfTheDayGenerator: RecipeOfTheDayGenerator = RecipeOfTheDayGenerator()
    
    @State private var isLoadingPreGeneration: Bool = false
    
    @State private var presentingRecipeOfTheDayGenerationSwipeViewModel: RecipeOfTheDayGenerationSwipeViewModel?
    
    private var sortedDailyRecipes: [Recipe] {
        dailyRecipes.sorted(by: {
            guard let type1String = $0.dailyRecipe_timeFrameID,
                  let type2String = $1.dailyRecipe_timeFrameID,
                  let type1 = RecipeOfTheDayView.TimeFrames(rawValue: type1String),
                  let type2 = RecipeOfTheDayView.TimeFrames(rawValue: type2String) else {
                return false
            }
            return type1.sortOrder < type2.sortOrder
        })
    }
    
    var body: some View {
        Group {
            let paddingAmount: CGFloat = 16
            if pantryItems.count == 0 {
                Button(action: onOpenAddToPantry) {
                    VStack {
                        Text("Daily Recipe")
                            .font(.custom(Constants.FontName.heavy, size: 24.0))
                        Text("Get daily recipes from your ingredients.")
                            .font(.custom(Constants.FontName.body, size: 17.0))
                        HStack {
                            Image(systemName: "plus")
                                .font(.custom(Constants.FontName.body, size: 20.0))
                            Text("Add to Pantry")
                                .font(.custom(Constants.FontName.heavy, size: 20.0))
                        }
                        .foregroundStyle(Colors.elementBackground)
                        .padding(.top)
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Colors.foreground.opacity(0.6))
                    .clipShape(RoundedRectangle(cornerRadius: 14.0))
                    .padding(.horizontal)
                }
                .foregroundStyle(Colors.foregroundText)
            } else {
                ScrollViewReader { proxy in
                    Group {
                        if #available(iOS 17.0, *) {
                            SingleAxisGeometryReader(axis: .horizontal) { geometry in
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack {
                                        ForEach(sortedDailyRecipes.indices, id: \.self) { index in
                                            let recipe = sortedDailyRecipes[index]
                                            if let dailyRecipeTimeFrameID = recipe.dailyRecipe_timeFrameID,
                                               let dailyRecipeTimeFrame = RecipeOfTheDayView.TimeFrames(rawValue: dailyRecipeTimeFrameID) {
                                                recipeCard(
                                                    recipe: recipe,
                                                    timeFrame: dailyRecipeTimeFrame)
                                                .padding()
                                                .frame(width: geometry.magnitude > paddingAmount * 2 ? geometry.magnitude - paddingAmount * 2 : 0, height: height)
                                                .background(Colors.foreground)
                                                .clipShape(RoundedRectangle(cornerRadius: 14.0))
                                                .scrollTargetLayout()
                                                .tag(index)
                                                //                                    .containerRelativeFrame(.horizontal)
                                                
                                            }
                                        }
                                        
                                        if recipeOfTheDayGenerator.isLoading {
                                            loadingCard
                                                .frame(width: geometry.magnitude > paddingAmount * 2 ? geometry.magnitude - paddingAmount * 2 : 0, height: height)
                                                .background(Colors.foreground)
                                                .clipShape(RoundedRectangle(cornerRadius: 14.0))
                                                .scrollTargetLayout()
                                                .tag(3)
                                            //                                    .containerRelativeFrame(.horizontal)
                                        }
                                    }
                                }
                                .scrollTargetBehavior(.paging)
                                .safeAreaPadding(.horizontal, paddingAmount)
                            }
                        } else {
                            SingleAxisGeometryReader(axis: .horizontal) { geometry in
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack {
                                        ForEach(sortedDailyRecipes.indices, id: \.self) { index in
                                            let recipe = sortedDailyRecipes[index]
                                            if let dailyRecipeTimeFrameID = recipe.dailyRecipe_timeFrameID,
                                               let dailyRecipeTimeFrame = RecipeOfTheDayView.TimeFrames(rawValue: dailyRecipeTimeFrameID) {
                                                recipeCard(
                                                    recipe: recipe,
                                                    timeFrame: dailyRecipeTimeFrame)
                                                .padding()
                                                .frame(width: geometry.magnitude > paddingAmount * 2 ? geometry.magnitude - paddingAmount * 2 : 0, height: height)
                                                .background(Colors.foreground)
                                                .clipShape(RoundedRectangle(cornerRadius: 14.0))
                                                .tag(index)
                                                //                                    .padding(paddingAmount / 4)
                                            }
                                        }
                                        
                                        if recipeOfTheDayGenerator.isLoading {
                                            loadingCard
                                                .padding()
                                                .frame(width: geometry.magnitude > paddingAmount * 2 ? geometry.magnitude - paddingAmount * 2 : 0, height: height)
                                                .background(Colors.foreground)
                                                .clipShape(RoundedRectangle(cornerRadius: 14.0))
                                                .tag(3)
                                            //                                    .padding(paddingAmount / 4)
                                        }
                                    }
                                    .padding(.horizontal, paddingAmount)
                                }
                            }
                        }
                    }
                    .task {
                        // Ensure there are pantry items, otherwise return
                        guard pantryItems.count > 0 else {
                            return
                        }
                        
                        // Ensure authToken
                        let authToken: String
                        do {
                            authToken = try await AuthHelper.ensure()
                        } catch {
                            // TODO: [Error Handling] Handle Errors
                            print("Error ensuring authToken in RecipeOfTheDayContainer... \(error)")
                            return
                        }
                        
                        // Process daily recipes
                        await recipeOfTheDayGenerator.processDailyRecipes(
                            dailyRecipes: dailyRecipes,
                            pantryItems: pantryItems,
                            authToken: authToken,
                            in: viewContext)
                        
                        // Scroll to card for current timeFrame
                        if let currentTimeFrame = RecipeOfTheDayView.TimeFrames.timeFrame(for: Date()) {
                            if dailyRecipes.count > currentTimeFrame.sortOrder {
                                await MainActor.run {
                                    withAnimation(.bouncy(duration: 0.5)) {
                                        proxy.scrollTo(currentTimeFrame.sortOrder)
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        .fullScreenCover(item: $presentingRecipeOfTheDayGenerationSwipeViewModel) { recipeOfTheDayGenerationSwipeViewModel in
            NavigationStack {
                RecipeOfTheDayGenerationSwipeView(
                    viewModel: recipeOfTheDayGenerationSwipeViewModel,
                    dailyRecipes: _dailyRecipes,
                    onDismiss: { presentingRecipeOfTheDayGenerationSwipeViewModel = nil })
                .toolbar {
                    LogoToolbarItem(foregroundColor: Colors.elementBackground)
                    
                    ToolbarItem(placement: .topBarTrailing) {
                        Button(action: {
                            presentingRecipeOfTheDayGenerationSwipeViewModel = nil
                        }) {
                            Text("Close")
                                .font(.heavy, 17.0)
                                .foregroundStyle(Colors.elementBackground)
                        }
                    }
                }
            }
        }
    }
    
    private var loadingCard: some View {
        VStack {
            Text("Loading \(RecipeOfTheDayView.TimeFrames.timeFrame(for: Date())?.displayString ?? "Daily Recipe")...")
                .font(.custom(Constants.FontName.heavy, size: 24.0))
            ProgressView()
        }
    }
    
    private func recipeCard(recipe: Recipe, timeFrame: RecipeOfTheDayView.TimeFrames) -> some View {
        Button(action: {
            onSelect(recipe)
        }) {
            RecipeOfTheDayView(
                recipe: recipe,
                timeFrame: timeFrame,
                onReload: {
                    presentingRecipeOfTheDayGenerationSwipeViewModel = RecipeOfTheDayGenerationSwipeViewModel(
                        recipeGenerationTimeFrame: timeFrame,
                        recipeGenerationSwipeViewModel: RecipeGenerationSwipeViewModel(
                            pantryItems: pantryItems.sorted(by: {$0.name ?? "" < $1.name ?? ""}),
                            suggestions: [],
                            input: "Select from this list and create a delicious \(timeFrame.displayString).",
                            generationAdditionalOptions: .normal))
                })
        }
        .foregroundStyle(Colors.foregroundText)
    }
    
}

#Preview {
    
    RecipeOfTheDayContainer(
        onSelect: { recipe in
        
        },
        onOpenAddToPantry: {
            
        })
    .environment(\.managedObjectContext, CDClient.mainManagedObjectContext)
    .frame(maxHeight: .infinity)
    .background(Colors.background)
    
}
