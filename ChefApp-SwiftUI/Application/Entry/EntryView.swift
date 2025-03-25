//
//  EntryView.swift
//  Barback
//
//  Created by Alex Coundouriotis on 9/20/23.
//

import Foundation
import PopupView
import SwiftUI

class EntryViewModel: ObservableObject, Identifiable {
    
    // Required
    
    /// The message displayed below the title in the entry view
    @Published var subtitleMessage: String
    
    /// Array of pantry items (ingredients) selected by the user
    @Published var selectedPantryItems: [PantryItem]
    
    /// Additional options for recipe generation (meal type, dietary restrictions, etc.)
    @Published var generationAdditionalOptions: RecipeGenerationAdditionalOptions
    
    /// Array of suggestions selected by the user from the suggestions grid
    @Published var selectedSuggestions: [String]
    
    /// Text entered by the user to describe the recipe they want
    @Published var promptText: String
    
    /// Controls whether the title "Create Recipe..." is displayed
    let showsTitle: Bool
    
    // Internal
    
    /// View model for the text input card at the bottom of the screen
    @Published var presentingEntryPromptCardViewModel: EntryPromptCardViewModel = EntryPromptCardViewModel(textFieldPlaceholders: [
        "Enter Prompt..."
    ])
    
    /// Tracks whether advanced options panel is expanded
    @Published var isDisplayingAdvancedOptions: Bool = false
    
    /// Tracks whether the pantry selection view is being displayed
    @Published var isShowingPantrySelectionView: Bool = false
    
    /// Initializes a new EntryViewModel with customizable properties
    /// - Parameters:
    ///   - subtitleMessage: The message shown below the title
    ///   - selectedPantryItems: Initial array of selected pantry items (defaults to empty)
    ///   - generationAdditionalOptions: Recipe generation options (defaults to normal)
    ///   - selectedSuggestions: Initial array of selected suggestions (defaults to empty)
    ///   - promptText: Initial text for the prompt field (defaults to empty)
    ///   - showsTitle: Whether to show the title "Create Recipe..." (defaults to true)
    init(
        subtitleMessage: String,
        selectedPantryItems: [PantryItem] = [],
        generationAdditionalOptions: RecipeGenerationAdditionalOptions = .normal,
        selectedSuggestions: [String] = [],
        promptText: String = "",
        showsTitle: Bool = true
    ) {
        self.subtitleMessage = subtitleMessage
        self.selectedPantryItems = selectedPantryItems
        self.generationAdditionalOptions = generationAdditionalOptions
        self.selectedSuggestions = selectedSuggestions
        self.promptText = promptText
        self.showsTitle = showsTitle
    }
    
}

/***
 EntryView - Recipe Creation Customization
 
 Shows when for the user to customize the reicpe generation inputs.
 - Primarily shown in RecipeGenerationSwipeView when clicking on the entry button
 */
struct EntryView: View {
    
    // Initialization
    
    @ObservedObject var viewModel: EntryViewModel
    let onGenerate: () -> Void
    let onDismiss: () -> Void
    
    // Instance
    
    @Environment(\.managedObjectContext) private var viewContext
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \PantryItem.updateDate, ascending: false)],
        animation: .default)
    private var pantryItems: FetchedResults<PantryItem>
    
    
    var body: some View {
        VStack {
            ScrollView {
                VStack {
                    HStack {
                        VStack(spacing: 0.0) {
                            if viewModel.showsTitle {
                                HStack {
                                    Text("Create Recipe...")
                                        .font(.custom(Constants.FontName.damion, size: 42.0))
                                    Spacer()
                                }
                                .padding(.top)
                                .padding([.leading, .trailing])
                                .fixedSize(horizontal: false, vertical: true)
                            }
                            
                            HStack {
                                Text(viewModel.subtitleMessage)
                                    .font(.custom(Constants.FontName.body, size: 17.0))
                                    .multilineTextAlignment(.leading)
                                Spacer()
                            }
                            .fixedSize(horizontal: false, vertical: true)
                            .padding(.top)
                            .padding([.leading, .trailing])
                            
                            EntrySuggestionsGrid(
                                selectedSuggestions: $viewModel.selectedSuggestions)
                            .padding(.top)
                            
                            PantryRecipeGenerationAdvancedOptionsView(
                                isDisplayingAdvancedOptions: $viewModel.isDisplayingAdvancedOptions,
                                generationAdditionalOptions: $viewModel.generationAdditionalOptions)
                            .padding(.top)
                        }
                    }
                    VStack(spacing: 0.0) {
                        Divider()
                        
                        // Add from pantry
                        VStack {
                            HStack {
                                Text("Tap to add ingredients from your pantry...")
                                    .font(.custom(Constants.FontName.bodyOblique, size: 14.0))
                                    .foregroundStyle(Colors.foregroundText)
                                    .padding([.leading, .trailing])
                                
                                Spacer()
                            }
                            .padding([.top, .bottom], 8)
                            
                            HStack {
                                PantrySelectionView(
                                    selectedPantryItems: $viewModel.selectedPantryItems,
                                    showsAdvancedOptions: false,
                                    generationAdditionalOptions: $viewModel.generationAdditionalOptions)
                            }
                        }
                        
                        Spacer(minLength: 80.0)
                    }
                }
                .onTapGesture {
                    KeyboardDismisser.dismiss()
                }
            }
            
            EntryPromptCard(
                viewModel: viewModel.presentingEntryPromptCardViewModel,
                entryViewModel: viewModel,
                onGenerate: onGenerate)
            .padding(.horizontal)
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Colors.background, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Create Recipes")
                    .font(.damion, 32)
                    .foregroundStyle(Colors.elementBackground)
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button(action: {
                    onDismiss()
                }) {
                    Text("Close")
                        .font(.heavy, 17)
                        .foregroundStyle(Colors.elementBackground)
                }
            }
        }
    }
    
}


#Preview {
    
    ZStack {
        Spacer()
    }
    .overlay {
        EntryView(
            viewModel: EntryViewModel(
                subtitleMessage: "AI Chef here, tell me what you want to recipe or get inspired from suggestions. 😊",
                selectedPantryItems: [],
                generationAdditionalOptions: .normal,
                selectedSuggestions: [],
                showsTitle: true
            ),
            onGenerate: {
                
            },
            onDismiss: {
                
            }
        )
        .background(Colors.background)
        .environment(\.managedObjectContext, CDClient.mainManagedObjectContext)
        .environmentObject(PremiumUpdater())
        .environmentObject(ProductUpdater())
        .environmentObject(RemainingUpdater())
    }
    
    
}
