//
//  IngredientsInputPanelComponentView.swift
//  Barback
//
//  Created by Alex Coundouriotis on 9/22/23.
//

import SwiftUI

struct IngredientsInputPanelComponentView: ComponentView {
    
    var panelComponent: PanelComponent
    var textFieldPanelComponentViewConfig: TextFieldPanelComponentViewConfig
    
    @Binding var isAddPantryItemPopupShowing: Bool
    @Binding var finalizedPrompt: String?
    @Binding var generationAdditionalOptions: RecipeGenerationAdditionalOptions
    
    @State private var isPantryShowing: Bool
    
    @State private var selectedPantryItems: [PantryItem] = []
    @State private var deselectedPantryItems: [PantryItem] = []
//    private var selectedPantryItemsBinding: Binding<[PantryItem]> {
//        Binding(
//            get: {
//                selectedPantryItems
//            },
//            set: { newValue in
//                selectedPantryItems = newValue
//                updateFinalizedPrompt()
//            })
//    }
    
    @State var text: String = ""
//    private var textBinding: Binding<String> {
//        Binding(
//            get: {
//                text
//            },
//            set: { newValue in
//                text = newValue
//                updateFinalizedPrompt()
//            })
//    }
    
    init(panelComponent: PanelComponent, textFieldPanelComponentViewConfig: TextFieldPanelComponentViewConfig, isAddPantryItemPopupShowing: Binding<Bool>, finalizedPrompt: Binding<String?>, generationAdditionalOptions: Binding<RecipeGenerationAdditionalOptions>) {
        self.panelComponent = panelComponent
        self.textFieldPanelComponentViewConfig = textFieldPanelComponentViewConfig
        self._isAddPantryItemPopupShowing = isAddPantryItemPopupShowing
        self._finalizedPrompt = finalizedPrompt
        self._generationAdditionalOptions = generationAdditionalOptions
        self._isPantryShowing = State(initialValue: panelComponent.requiredUnwrapped)
    }
    
    func updateFinalizedPrompt() {
        // Ensure there is either text or at least one selected bar item, otherwise set finalizedPrompt to nil and return
        guard !text.isEmpty || !selectedPantryItems.isEmpty else {
            finalizedPrompt = nil
            return
        }
        
        let panelComponentString = panelComponent.promptPrefix == nil ? "" : panelComponent.promptPrefix! + " "
        let selectedPantryItemsString = selectedPantryItems.isEmpty ? "" : selectedPantryItems.compactMap({$0.name}).joined(separator: ", ") + " "
        let textString = text.isEmpty ? "" : text
        
        finalizedPrompt = panelComponentString + selectedPantryItemsString + textString
    }
    
    
    var body: some View {
        VStack(spacing: 2) {
            TitlePanelComponentView(
                panelComponent: panelComponent)
            PanelTextField(
                placeholder: textFieldPanelComponentViewConfig.placeholderUnwrapped,
                text: $text)
            .onChange(of: selectedPantryItems) { newSelectedPantryItems in
                updateFinalizedPrompt()
            }
            PantrySelectionMiniView(
                selectedPantryItems: $selectedPantryItems,
                generationAdditionalOptions: $generationAdditionalOptions,
                axis: .horizontal)
            .onChange(of: text) { newText in
                updateFinalizedPrompt()
            }
            ExampleComponentView(
                panelComponent: panelComponent)
        }
    }
    
}

@available(iOS 17, *)
#Preview(traits: .sizeThatFitsLayout) {
    let textFieldPanelComponentViewConfig = TextFieldPanelComponentViewConfig()
    
    let panelComponent = PanelComponent(
        input: .ingredientsInput(textFieldPanelComponentViewConfig),
        title: "Title",
        promptPrefix: "Prompt Prefix")
    
    
    return IngredientsInputPanelComponentView(
        panelComponent: panelComponent,
        textFieldPanelComponentViewConfig: textFieldPanelComponentViewConfig,
        isAddPantryItemPopupShowing: .constant(false),
        finalizedPrompt: .constant("asdfasdf"),
        generationAdditionalOptions: .constant(.normal))
    .background(Colors.background)
}
