//
//  BarSelectionPanelComponentView.swift
//  Barback
//
//  Created by Alex Coundouriotis on 9/22/23.
//

import PopupView
import SwiftUI

struct PantrySelectionPanelComponentView: ComponentView {
    
    var panelComponent: PanelComponent
    
    @Binding var isAddPantryItemPopupShowing: Bool
    @Binding var finalizedPrompt: String?

    
    @State private var isPantryShowing: Bool
    @State private var selectedPantryItems: [PantryItem] = []
    @State private var generationAdditionalOptions: RecipeGenerationAdditionalOptions = .normal
    
    init(panelComponent: PanelComponent, isAddPantryItemPopupShowing: Binding<Bool>, finalizedPrompt: Binding<String?>) {
        self.panelComponent = panelComponent
        self._isAddPantryItemPopupShowing = isAddPantryItemPopupShowing
        self._finalizedPrompt = finalizedPrompt
        self._isPantryShowing = State(initialValue: panelComponent.requiredUnwrapped)
    }
    
    /* BODY */
    var body: some View {
        
        VStack(spacing: 2) {
            TitlePanelComponentView(
                panelComponent: panelComponent)
            PantrySelectionMiniView(
                selectedPantryItems: $selectedPantryItems,
                showsAdvancedOptions: false,
                generationAdditionalOptions: $generationAdditionalOptions,
                axis: .horizontal)
            .padding([.leading, .trailing], -16)
            .onChange(of: selectedPantryItems) { newSelectedPantryItems in
                updateFinalizedPrompt()
            }
            ExampleComponentView(
                panelComponent: panelComponent)
        }
    }
    
    /* PRIVATE FUNCTIONOS */
    private func updateFinalizedPrompt() {
        guard selectedPantryItems.count > 0 else {
            finalizedPrompt = nil
            return
        }
        
        finalizedPrompt = (panelComponent.promptPrefix == nil ? "" : panelComponent.promptPrefix! + " ") + selectedPantryItems.compactMap({$0.name ?? $0.category}).joined(separator: ", ")
    }
    
}

@available(iOS 17, *)
#Preview(traits: .sizeThatFitsLayout) {
    let panelComponent = PanelComponent(
        input: .barSelection,
        title: "Title",
        example: "ex. Example",
        detailTitle: "Detail Title",
        detailText: "Detail Text",
        promptPrefix: "Prompt Prefix",
        required: false)
    
    return PantrySelectionPanelComponentView(
        panelComponent: panelComponent,
        isAddPantryItemPopupShowing: .constant(false),
        finalizedPrompt: .constant("asdf"))
    .background(Colors.background)
}
