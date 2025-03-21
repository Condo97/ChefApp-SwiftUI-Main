//
//  PantrySelectionView.swift
//  ChefApp-SwiftUI
//
//  Created by Alex Coundouriotis on 6/21/24.
//

import SwiftUI

struct PantrySelectionView: View {
    
    @Binding var selectedPantryItems: [PantryItem]
    @State var showsAdvancedOptions: Bool = true
    @Binding var generationAdditionalOptions: RecipeGenerationAdditionalOptions
    
    
    @Namespace private var namespace
    
    @Environment(\.managedObjectContext) var viewContext
    
    
    @SectionedFetchRequest(
        sectionIdentifier: \PantryItem.category,
        sortDescriptors: [
            NSSortDescriptor(keyPath: \PantryItem.category, ascending: true),
            NSSortDescriptor(keyPath: \PantryItem.name, ascending: true)
        ],
        animation: .default)
    private var sectionedPantryItems: SectionedFetchResults<String?, PantryItem>
    
    
    @State private var isDisplayingAdvancedOptions: Bool = false
    
    @State private var presentingAddToPantryViewModel: AddToPantryViewModel?
    
    
    
    var body: some View {
        VStack(alignment: .leading) {
            PantryItemsContainer(
                selectedItems: $selectedPantryItems,
                editMode: .constant(.inactive),
                showsContextMenu: true,
                selectionColor: .green)
            
            HStack {
                Button(action: {
                    HapticHelper.doLightHaptic()
                    
                    withAnimation {
                        presentingAddToPantryViewModel = AddToPantryViewModel()
                    }
                }) {
                    Text("+ Add to Pantry")
                        .font(.custom(Constants.FontName.heavy, size: 17.0))
                        .padding([.top, .bottom], 8)
                        .padding([.leading, .trailing])
                        .foregroundColor(Colors.elementBackground)
                        .background(Colors.foreground)
                        .clipShape(RoundedRectangle(cornerRadius: 20.0))
                }
                .padding(.top)
                .padding([.leading, .trailing])
                
//                Spacer()
            }
            
            if showsAdvancedOptions {
                selectionButtons
            }
        }
        // Add to pantry popup
        .addToPantryPopup(viewModel: $presentingAddToPantryViewModel, showCameraOnAppear: false)
    }
    
    
    var selectionButtons: some View {
        PantryRecipeGenerationAdvancedOptionsView(
            isDisplayingAdvancedOptions: $isDisplayingAdvancedOptions,
            generationAdditionalOptions: $generationAdditionalOptions)
    }
    
    
    func pantryItemButton(for selectedPantryItem: PantryItem) -> some View {
        KeyboardDismissingButton(action: {
            HapticHelper.doLightHaptic()
            
            // TODO: Turn green and add to generate list or something when tapped
            if !selectedPantryItems.contains(where: {$0 == selectedPantryItem}) {
                withAnimation(.bouncy) {
                    selectedPantryItems.append(selectedPantryItem)
                }
            } else {
                withAnimation(.bouncy) {
                    selectedPantryItems.removeAll(where: {$0 == selectedPantryItem})
                }
            }
        }) {
            PantryItemView(pantryItem: selectedPantryItem)
                .frame(maxHeight: .infinity)
        }
        .padding([.top, .bottom], 8)
        .padding([.leading, .trailing], 16)
        .background(
            selectedPantryItems.contains(where: {$0 == selectedPantryItem})
            ?
            Color(uiColor: .systemGreen).opacity(0.4)
            :
                Colors.foreground
        )
        .cornerRadius(14.0)
    }
    
    
}

#Preview {
    PantrySelectionView(
        selectedPantryItems: .constant([]),
        generationAdditionalOptions: .constant(.normal))
        .background(Colors.background)
        .environment(\.managedObjectContext, CDClient.mainManagedObjectContext)
        .environmentObject(PremiumUpdater())
        .environmentObject(ProductUpdater())
        .environmentObject(RemainingUpdater())
}

