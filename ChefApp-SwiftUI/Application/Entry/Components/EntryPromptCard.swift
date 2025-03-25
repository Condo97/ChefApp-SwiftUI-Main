//
//  EntryPromptCard.swift
//  Barback
//
//  Created by Alex Coundouriotis on 9/20/23.
//

import Foundation
import SwiftUI

class EntryPromptCardViewModel: ObservableObject {
    
    // Required
    
    /// Controls whether to display the "Create" text in the submit button
    @Published var showsCraftText: Bool = false
    
    /// Collection of placeholder texts that can be displayed in the input field
    var textFieldPlaceholders: [String]
    
    // Internal
    
    /// Current index into the textFieldPlaceholders array to determine which placeholder to show
    @State var textFieldPlaceholderIndex: Int = 0
    
    /// Matched geometry effect identifier for the submit button background animation
    @State var craftButtonBackgroundMatchedGeometryEffectID = "craftButtonBackground"
    
    /// Matched geometry effect identifier for the submit button text animation
    @State var craftButtonTextMatchedGeometryEffectID = "craftButtonText"
    
    /// Matched geometry effect identifier for the submit button arrow animation
    @State var craftButtonArrowMatchedGeometryEffectID = "craftButtonArrow"
    
    /// Stores previously shown suggestions to manage suggestion history
    @State var previousSuggestions: [String] = []
    
    /// Vertical offset value for positioning elements in the view
    @State var yOffset: CGFloat = 0.0
    
    /// Initializes the EntryPromptCard view model with configurable parameters
    /// - Parameters:
    ///   - showsCraftText: Whether to show the "Create" text in the submit button
    ///   - textFieldPlaceholders: Array of placeholder texts to display in the input field
    init(
        showsCraftText: Bool = false,
        textFieldPlaceholders: [String]
    ) {
        self.showsCraftText = showsCraftText
        self.textFieldPlaceholders = textFieldPlaceholders
    }
    
}

/// A card component that handles recipe creation inputs, including pantry items selection,
/// text input, and suggestions with a customizable submit button
struct EntryPromptCard: View {
    
    /// View model containing card-specific state and configuration
    @ObservedObject var viewModel: EntryPromptCardViewModel
    
    /// View model containing the entry view state (prompt text, pantry items, and suggestions)
    @ObservedObject var entryViewModel: EntryViewModel
    
    /// Closure called when the user taps the generate/submit button
    let onGenerate: () -> Void
    
    /// System color scheme for adaptive styling
    @Environment(\.colorScheme) private var colorScheme
    
    /// Namespace for coordinating matched geometry effects animations
    @Namespace private var namespace
    
    /// Focus state for controlling keyboard focus on the text field
    @FocusState private var isTextFieldFocused: Bool
    
    /// Object responsible for handling recipe generation requests
    @StateObject var recipeGenerator: RecipeGenerator = RecipeGenerator()
    
    /// Determines if the submit button should be disabled based on content and generation state
    /// - Returns: true when the recipe is being created or when all input fields are empty
    var submitButtonDisabled: Bool {
        recipeGenerator.isCreating || (entryViewModel.promptText.isEmpty && entryViewModel.selectedPantryItems.isEmpty && entryViewModel.selectedSuggestions.isEmpty)
    }
    
    
    /// The main body of the view defining the layout and appearance of the card
    var body: some View {
        ZStack {
//            let _ = Self._printChanges()
            VStack {
                ZStack {
                        VStack(spacing: 0.0) {
                            pantryItemList
                            
                            HStack {
                                inputField
                                
                                submitButton
                            }
                            
                            if !entryViewModel.selectedSuggestions.isEmpty {
                                suggestionsList
                                    .padding([.leading, .trailing])
                                    .padding(.bottom, 4)
                            }
                        }
                        .background(Colors.foreground)
                        .clipShape(RoundedRectangle(cornerRadius: 20.0))
                }
            }
        }
    }
    
    /// Horizontal scrollable list of selected pantry items with removal capability
    var pantryItemList: some View {
        ScrollView(.horizontal) {
            HStack {
                Spacer()
                ForEach(entryViewModel.selectedPantryItems.reversed()) { selectedPantryItem in
                    if let selectedPantryItemName = selectedPantryItem.name {
                        Button(action: {
                            HapticHelper.doLightHaptic()
                            
                            entryViewModel.selectedPantryItems.removeAll(where: {$0 == selectedPantryItem})
                        }) {
                            Text(selectedPantryItemName)
                                .font(.custom(Constants.FontName.body, size: 12.0))
                            Text(Image(systemName: "xmark"))
                                .font(.custom(Constants.FontName.body, size: 12.0))
                        }
                        .padding(8)
                        .foregroundStyle(Colors.elementBackground)
                        .background(Colors.background)
                        .clipShape(RoundedRectangle(cornerRadius: 14.0))
                        .padding(.top, 4)
                    }
                }
            }
        }
        .scrollIndicators(.never)
    }
    
    /// Text input field for the user's recipe prompt with customizable placeholder
    var inputField: some View {
        TextField("", text: $entryViewModel.promptText, axis: .vertical)
            .textFieldTickerTint(colorScheme == .light ? Colors.elementBackground : Colors.foregroundText)
            .keyboardDismissingTextFieldToolbar("Done", color: Colors.elementBackground)
            .font(.custom(Constants.FontName.medium, size: 17.0))
            .placeholder(when: entryViewModel.promptText.isEmpty) {
                Text(viewModel.textFieldPlaceholders[viewModel.textFieldPlaceholderIndex])
                    .font(.custom(Constants.FontName.body, size: 17.0))
                    .foregroundStyle(Colors.foregroundText)
                    .opacity(0.4)
            }
            .focused($isTextFieldFocused)
            .padding()
    }
    
    /// Button to show the input field and create a recipe with animated transitions
    var showInputFieldButton: some View {
        Button(action: {
            // Do light haptic
            HapticHelper.doLightHaptic()
            
//            // Show entry view
//            withAnimation {
//                isShowingEntryView = true
//            }
        }) {
            ZStack {
                Spacer()
                Text("Create Recipe")
                    .font(.custom("copperplate-bold", size: 24.0))
                    .foregroundStyle(Colors.elementText)
                    .matchedGeometryEffect(id: viewModel.craftButtonTextMatchedGeometryEffectID, in: namespace)
                
                HStack {
                    Spacer()
                    
                    Text(recipeGenerator.isCreating ? "" : "\(Image(systemName: "arrow.right"))")
                        .font(.custom("copperplate-bold", size: 17.0))
                        .foregroundStyle(Colors.elementText)
                        .matchedGeometryEffect(id: viewModel.craftButtonArrowMatchedGeometryEffectID, in: namespace)
                    
                    if recipeGenerator.isCreating {
                        ProgressView()
                            .tint(Colors.elementText)
                    }
                }
                Spacer()
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 14.0)
                    .fill(Colors.elementBackground)
                    .matchedGeometryEffect(id: viewModel.craftButtonBackgroundMatchedGeometryEffectID, in: namespace))
            .clipShape(RoundedRectangle(cornerRadius: 20.0))
        }
        .bounceable()
    }
    
    /// Flexible layout for displaying selected recipe suggestions with adaptive width
    var suggestionsList: some View {
        SingleAxisGeometryReader(axis: .horizontal) { geo in
            HStack {
                FlexibleView(availableWidth: geo.magnitude, data: entryViewModel.selectedSuggestions, spacing: 8.0, alignment: .leading, content: { suggestion in
                    Text(suggestion)
                        .font(.custom(Constants.FontName.medium, size: 12.0))
                        .foregroundStyle(Colors.foregroundText)
                        .padding(.horizontal, 4)
                        .padding(.vertical, 2)
                        .background(Colors.foreground)
                        .clipShape(Capsule())
                        .padding(.top, -6)
                    
                })
                
                Spacer()
            }
        }
    }
    
    /// Submit button with conditional text display and loading state for recipe generation
    var submitButton: some View {
        ZStack {
            KeyboardDismissingButton(action: {
                HapticHelper.doLightHaptic()
                
                // TODO: Do enable/disable stuff, for action generate
                withAnimation {
                    onGenerate()
                }
            }) {
                VStack {
                    ZStack {
                        HStack(spacing: 8.0) {
                            // TODO: Make this hug the bottom as the user keeps typing in text
                            
                            if viewModel.showsCraftText {
                                Text("Create")
                                    .font(.custom("copperplate-bold", size: 19.0))
                                    .foregroundStyle(Colors.elementText)
                                    .matchedGeometryEffect(id: viewModel.craftButtonTextMatchedGeometryEffectID, in: namespace)
                            }
                            
                            ZStack {
                                Text(recipeGenerator.isCreating ? "" : "\(Image(systemName: "arrow.up"))")
                                    .font(.custom("copperplate-bold", size: 17.0))
                                    .foregroundStyle(Colors.elementText)
                                    .matchedGeometryEffect(id: viewModel.craftButtonArrowMatchedGeometryEffectID, in: namespace)
                                
                                if recipeGenerator.isCreating {
                                    ProgressView()
                                        .tint(Colors.elementText)
                                }
                            }
                        }
                    }
                    .padding(8)
                }
            }
            .background(
                ZStack {
                    if viewModel.showsCraftText {
                        RoundedRectangle(cornerRadius: 24.0)
                            .matchedGeometryEffect(id: viewModel.craftButtonBackgroundMatchedGeometryEffectID, in: namespace)
                    } else {
                        RoundedRectangle(cornerRadius: 24.0)
                            .matchedGeometryEffect(id: viewModel.craftButtonBackgroundMatchedGeometryEffectID, in: namespace)
                            .aspectRatio(contentMode: .fit)
                    }
                }
                .foregroundStyle(Colors.elementBackground)
            )
            .disabled(submitButtonDisabled)
            .opacity(submitButtonDisabled ? 0.4 : 1.0)
            .bounceable(disabled: submitButtonDisabled)
        }
//        .frame(width: 32.0, height: 32.0)
        .aspectRatio(contentMode: .fill)
        .padding([.trailing], 8)
//        .onDisappear {
//            // Dismiss entry view TODO: Is this a good place to do this?
//            isShowingEntryView = false
//        }
    }
    
}

/// Preview provider for EntryPromptCard that demonstrates the component with sample data
#Preview {
    
    /// Sample content view that hosts the EntryPromptCard with test data
    struct ContentView: View {
        
        @State var inputFieldText = "Input Field Text"
        @State var suggestionButtonPressed: Bool = false
        @State var selectedSuggestions: [String] = []
        
        /// Sample placeholder texts to display in the input field
        private let textFieldPlaceholders = [
            "Test 1",
            "Test 2",
            "Tee hee :)"
        ]
        
        /// Sample suggestion texts that can be added to the card
        private let suggestions = [
            "Suggestion 1",
            "Another suggestion",
            "a third suggestion!"
        ]
        
        @State private var selectedSuggestionIndex: Int = 0
        
        var body: some View {
            VStack {
                Button(action: {
                    HapticHelper.doLightHaptic()
                    
                    if selectedSuggestionIndex >= suggestions.count {
                        selectedSuggestions.removeAll()
                        selectedSuggestionIndex = 0
                    } else {
                        selectedSuggestions.append(suggestions[selectedSuggestionIndex])
                        
                        selectedSuggestionIndex += 1
                    }
                }) {
                    Text("Change Suggestion Text")
                        .foregroundStyle(.blue)
                }
                
                EntryPromptCard(
                    viewModel: EntryPromptCardViewModel(textFieldPlaceholders: textFieldPlaceholders),
                    entryViewModel: EntryViewModel(subtitleMessage: "Subtitle Message"),
                    onGenerate: {
                        
                    })
//                EntryPromptCard(
//                    selectedPantryItems: .constant([]),
//                    inputFieldText: $inputFieldText,
////                    isShowingEntryView: .constant(true),
//                    selectedSuggestions: $selectedSuggestions,
//                    textFieldPlaceholders: textFieldPlaceholders,
//                    onGenerate: {
//                        
//                    })
                .padding()
                .background(Colors.background)
                //            .cornerRadius(28.0)
            }
        }
    }
    
    return ContentView()
}
