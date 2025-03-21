//
//  PanelView.swift
//  Barback
//
//  Created by Alex Coundouriotis on 9/21/23.
//

import CoreData
import Foundation
import SwiftUI

struct PanelView: View {
    
    @State var panel: Panel
    @Binding var isShowing: Bool
    
    
    @Environment(\.presentationMode) private var presentationMode: Binding<PresentationMode>
    @Environment(\.requestReview) private var requestReview
    
    @EnvironmentObject private var premiumUpdater: PremiumUpdater
    @EnvironmentObject private var remainingUpdater: RemainingUpdater

    var btnBack : some View { Button(action: {
            HapticHelper.doLightHaptic()
        
            self.presentationMode.wrappedValue.dismiss()
        }) {
            HStack {
                Text("Go Back")
                    .foregroundStyle(.black)
            }
        }
    }
    
    @StateObject private var adOrReviewCoordinator = AdOrReviewCoordinator()
    
    @State private var generationAdditionalOptions: RecipeGenerationAdditionalOptions = .normal
    
    @State private var finalizedPrompt: String = ""
    
    @State private var isAddBarItemPopupShowing: Bool = false
    
    @State private var isShowingUltraView: Bool = false
    
    @GestureState private var dragOffset = CGSize.zero
    
    @State private var alertShowingGenerationError: Bool = false
    @State private var alertShowingCapReached: Bool = false
    
    @State private var presentingRecipeGenerationListViewModel: RecipeGenerationListViewModel?
    
    
    private var submitButtonDisabled: Bool {
        finalizedPrompt == ""
    }
    
    
    var body: some View {
        ZStack {
            VStack {
//                header
                
                ScrollView {
                    VStack {
                        // Header
                        
                        // Title Card
                        titlePanelCard
                        
                        // Panels
                        panelsStack
                            .onChange(of: panel.components) { newPanelComponents in
                                updateFinalizedPrompt()
                            }
                        
                    }
                    .padding()
                }
                
                Spacer()
                
                // Submit Button
                submitButton
                
                Spacer()
            }
        }
        .toolbar {
            LogoToolbarItem()
            UltraToolbarItem(color: Colors.navigationItemColor)
        }
        .toolbarBackground(Colors.secondaryBackground, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .fullScreenCover(item: $presentingRecipeGenerationListViewModel) { recipeGenerationListViewModel in
            // TODO: Is it okay to have false for useAllIngredients here, or should it be true or defined in the panel spec and optionally get user input
            RecipeGenerationListView(
                viewModel: recipeGenerationListViewModel,
                onDismiss: { presentingRecipeGenerationListViewModel = nil },
                didSaveRecipe: { _ in
                    // Dismiss
                    presentingRecipeGenerationListViewModel = nil
                    isShowing = false
                    
                    // Show ad or review
                    Task {
                        await adOrReviewCoordinator.showWithCooldown(isPremium: premiumUpdater.isPremium)
                    }
                })
            .background(Colors.background)
        }
        .capReachedErrorAlert(isPresented: $alertShowingCapReached, isShowingUltraView: $isShowingUltraView)
        .interstitialInBackground(
            interstitialID: Keys.GAD.Interstitial.panelViewGenerate,
            disabled: premiumUpdater.isPremium,
            isPresented: $adOrReviewCoordinator.isShowingInterstitial)
        .ultraViewPopover(isPresented: $isShowingUltraView)
        .onReceive(adOrReviewCoordinator.$requestedReview) { newValue in
            if newValue {
                requestReview()
            }
        }
        .alert("Error Crafting", isPresented: $alertShowingGenerationError, actions: {
            Button("Close", role: .cancel, action: {
                
            })
        }) {
            Text("There was an issue crafting your recipe. Please try again later.")
        }
        
    }
    
    var titlePanelCard: some View {
        HStack {
            HStack {
                Spacer()
                // Emoji
                Text(panel.emoji)
                    .font(.custom(Constants.FontName.black, size: 38.0))
                    .lineLimit(.max)
                    .multilineTextAlignment(.center)
                
                // Title and Summary
                VStack {
                    HStack {
                        // Card Title
                        Text(panel.title)
                            .font(.custom(Constants.FontName.black, size: 20.0))
                            .lineLimit(.max)
                            .multilineTextAlignment(.center)
                            .minimumScaleFactor(0.5)
                    }
                    HStack {
                        // Card Summary
                        Text(panel.summary)
                            .font(.custom(Constants.FontName.body, size: 14.0))
                            .multilineTextAlignment(.center)
                            .minimumScaleFactor(0.5)
                    }
                }
                Spacer()
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 28.0)
                .fill(Colors.foreground)
        )
    }
    
    var panelsStack: some View {
        ForEach($panel.components) { $component in
            switch component.input {
            case .barSelection:
                PantrySelectionPanelComponentView(
                    panelComponent: component,
                    isAddPantryItemPopupShowing: $isAddBarItemPopupShowing,
                    finalizedPrompt: $component.finalizedPrompt)
            case .dropdown(let viewConfig):
                DropdownPanelComponentView(
                    panelComponent: component,
                    dropdownPanelComponentViewConfig: viewConfig,
                    finalizedPrompt: $component.finalizedPrompt)
            case .ingredientsInput(let viewConfig):
                IngredientsInputPanelComponentView(
                    panelComponent: component,
                    textFieldPanelComponentViewConfig: viewConfig,
                    isAddPantryItemPopupShowing: $isAddBarItemPopupShowing,
                    finalizedPrompt: $component.finalizedPrompt,
                    generationAdditionalOptions: $generationAdditionalOptions)
            case .textField(let viewConfig):
                TextFieldPanelComponentView(
                    panelComponent: component,
                    textFieldPanelComponentViewConfig: viewConfig,
                    finalizedPrompt: $component.finalizedPrompt)
            }
            Spacer(minLength: 20)
        }
    }
    
    var submitButton: some View {
        Button(action: {
            HapticHelper.doMediumHaptic()
            
            withAnimation {
                presentingRecipeGenerationListViewModel = RecipeGenerationListViewModel(
                    pantryItems: [],
                    suggestions: [],
                    input: finalizedPrompt,
                    generationAdditionalOptions: generationAdditionalOptions)
            }
        }) {
            Spacer()
            ZStack {
                Text("Create Recipe...")
                    .font(.custom(Constants.FontName.black, size: 24.0))
                    .foregroundStyle(Colors.elementText)
                HStack {
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.custom(Constants.FontName.heavy, size: 24.0))
                        .foregroundStyle(Colors.elementText)
                }
            }
            Spacer()
        }
        .disabled(submitButtonDisabled)
        .modifier(CardModifier(backgroundColor: Colors.elementBackground))
        .bounceable(disabled: submitButtonDisabled)
        .opacity(submitButtonDisabled ? 0.4 : 1.0)
        .padding()
    }
    
    private func updateFinalizedPrompt() {
        // TODO: I don't think that it's using the "prompt" text when creating the finalized prompt, so maybe that's something that needs to be fixed?
        
        let commaSeparator = ", "
        
        // Build completeFinalizedPrompt, ensuring that all required values' finalizedPrompts are not nil and return
        var completeFinalizedPrompt = ""
        for i in 0..<panel.components.count {
            let component = panel.components[i]
            
            // Unswrap finalizedPrompt, otherwise either return nil or continue
            guard let finalizedPrompt = component.finalizedPrompt else {
                // If required, return nil
                if component.requiredUnwrapped {
                    finalizedPrompt = ""
                    return
                }
                
                // Otherwise, continue
                continue
            }
            
            // Append to completeFinalizedPrompt
            completeFinalizedPrompt.append(finalizedPrompt)
            
            // If not the last index in panel.components, append the comma separator
            if i < panel.components.count - 1 {
                completeFinalizedPrompt.append(commaSeparator)
            }
        }
        
        finalizedPrompt = completeFinalizedPrompt
    }
    
}


#Preview {
//    @Namespace var namespace
    
    return PanelView(
        panel: Panel(
            emoji: "😊",
            title: "This is a Title",
            summary: "This is the description for the title",
            prompt: "Prompt",
            components: [
                PanelComponent(
                    input: .textField(TextFieldPanelComponentViewConfig(
                        placeholder: "Text Field Panel Component Placeholder")),
                    title: "Text Field Panel Title",
                    detailTitle: "Test Detail Title",
                    detailText: "Test Detail Text",
                    promptPrefix: "Text Field Panel Component Prompt Prefix",
                    required: true),
                PanelComponent(
                    input: .dropdown(DropdownPanelComponentViewConfig(
                        items: [
                            "First item",
                            "Second item"
                        ])),
                    title: "Dropdown Panel Title",
                    detailTitle: "Test Detail Title",
                    detailText: "Test Detail Text",
                    promptPrefix: "Dropdown Panel Prompt Prefix",
                    required: true),
                PanelComponent(
                    input: .barSelection,
                    title: "Bar Selection Component Title",
                    promptPrefix: "Bar Selection Component Prompt Prefix",
                    required: true)
        ]),
        isShowing: .constant(true))
        .environment(\.managedObjectContext, CDClient.mainManagedObjectContext)
        .environmentObject(PremiumUpdater())
        .environmentObject(ProductUpdater())
        .environmentObject(RemainingUpdater())
        .background(Colors.background)
}
