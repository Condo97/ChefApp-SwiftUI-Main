//
//  AddToPantryView.swift
//  ChefApp-SwiftUI
//
//  Created by Alex Coundouriotis on 12/15/24.
//

import CoreData
import SwiftUI

class AddToPantryViewModel: ObservableObject, Identifiable {
    
    @Published var automaticEntryText: String = ""
    @Published var automaticEntryItems: [String] = []
    
    @Published var isLoading: Bool = false
    
    @Published var isShowingCaptureCameraView: Bool = false
    
    @Published var duplicatePantryItemNames: [String] = []
    
    @Published var alertShowingDuplicateAutomaticEntryItem: Bool = false
    @Published var alertShowingDuplicateObjectWhenInserting: Bool = false
    
    private var isAutoSubmitButtonEnabled: Bool {
        !automaticEntryText.isEmpty || !automaticEntryItems.isEmpty
    }
    
    func parseAutomaticEntryText() {
        // Loop through automaticEntryText split by comma separator
        for item in automaticEntryText.split(separator: ", ") {
            // Ensure automaticEntryText is not in automaticEntryItems, otherwise return
            guard !automaticEntryItems.contains(String(item)) else {
                alertShowingDuplicateAutomaticEntryItem = true
                return
            }
            
            // Take automaticEntryText and add it to automaticEnteredItems
            automaticEntryItems.append(String(item))
        }
        
        // Set automaticEntryText to blank
        automaticEntryText = ""
    }
    
    func savePantryItems(pantryItemsParser: PantryItemsParser, in managedContext: NSManagedObjectContext) async {
        defer { DispatchQueue.main.async { self.isLoading = false } }
        await MainActor.run { isLoading = true }
        
        // Save pantry items
        do {
            try await pantryItemsParser.parseSavePantryItems(
                input: automaticEntryItems.joined(separator: ", ") + "\n" + automaticEntryText,
                in: managedContext)
            
            // Do success haptic
            HapticHelper.doSuccessHaptic()
        } catch PantryItemPersistenceError.duplicatePantryItemNames(let duplicatePantryItemNames) {
            // Do warning haptic
            HapticHelper.doWarningHaptic()
            
            // Set instance dupliactePantryItemsNames to dupliactePantryItemNames from error
            self.duplicatePantryItemNames = duplicatePantryItemNames
            alertShowingDuplicateObjectWhenInserting = true
        } catch {
            // TODO: Handle errors
            print("Error parsing and saving bar items in body in InsertPantryItemView... \(error)")
        }
    }
    
}

struct AddToPantryView: View {
    
    @ObservedObject var viewModel: AddToPantryViewModel
    let showCameraOnAppear: Bool
    let onDismiss: () -> Void
    
    @Environment(\.managedObjectContext) private var viewContext
    
    @StateObject private var pantryItemsParser: PantryItemsParser = PantryItemsParser()
    
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                // Title
                Text("Add to Pantry")
                    .font(.custom(Constants.FontName.black, size: 24.0))
                    .padding(.bottom, 8)
                    .padding(.horizontal)
                
                AddToPantryTextInputEntry(
                    entryText: $viewModel.automaticEntryText,
                    onParseEntryText: viewModel.parseAutomaticEntryText)
                
                // Add with Camera Button
                AddToPantryAddWithCameraButton(
                    onAddWithCamera: {
                        viewModel.isShowingCaptureCameraView = true
                    }
                )
                
                // Parsed Items List
                AddToPantryList(
                    automaticEntryItems: $viewModel.automaticEntryItems,
                    pantryItemsParser: pantryItemsParser)
            }
        }
        .background(Colors.background)
        .overlay {
            // Saving overlay
            if pantryItemsParser.isLoadingParseSavePantryItems {
                ZStack {
                    Colors.background
                        .opacity(0.6)
                    VStack {
                        Text("Saving Pantry")
                            .font(.heavy, 20)
                        ProgressView()
                    }
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Colors.background, for: .navigationBar)
        .toolbar {
            // Logo
            LogoToolbarItem(foregroundColor: Colors.elementBackground)
            
            // Cancel
            ToolbarItem(placement: .topBarLeading) {
                Button(action: {
                    // Dismiss
                    onDismiss()
                }) {
                    Text("Cancel")
                        .font(.body, 17.0)
                        .foregroundStyle(Colors.elementBackground)
                }
                .disabled(viewModel.isLoading)
            }
            
            // Save
            ToolbarItem(placement: .topBarTrailing) {
                Button(action: {
                    Task {
                        // Save and dismiss
                        await viewModel.savePantryItems(pantryItemsParser: pantryItemsParser, in: viewContext)
                        await MainActor.run { onDismiss() }
                    }
                }) {
                    Text("Save")
                        .font(.heavy, 17.0)
                        .foregroundStyle(Colors.elementBackground)
                }
                .disabled(viewModel.isLoading)
            }
        }
        .onAppear {
            // Show camera on appear if necessary
            if showCameraOnAppear {
                viewModel.isShowingCaptureCameraView = true
            }
        }
        
        // Duplicate entry alert
        .alert("Duplicate Entry", isPresented: $viewModel.alertShowingDuplicateAutomaticEntryItem, actions: {
            Button("Done", role: .cancel, action: {
                
            })
        }) {
            Text("This item is already in your list to add to pantry.")
        }
        
        // Duplicate item alert
        .alert("Duplicate Item", isPresented: $viewModel.alertShowingDuplicateObjectWhenInserting, actions: {
            Button("Done", role: .cancel, action: onDismiss)
        }) {
            Text("Duplicate pantry items found and won't be added:\n" + viewModel.duplicatePantryItemNames.joined(separator: ", "))
        }
        
        // Capture camera view
        .addToPantryCaptureCameraPopup(
            isPresented: $viewModel.isShowingCaptureCameraView,
            automaticEntryItems: $viewModel.automaticEntryItems,
            pantryItemsParser: pantryItemsParser)
    }
    
}

extension View {
    
    func addToPantryPopup(viewModel: Binding<AddToPantryViewModel?>, showCameraOnAppear: Bool) -> some View {
        self
            .fullScreenCover(item: viewModel) { unwrappedViewModel in
                NavigationStack {
                    AddToPantryView(
                        viewModel: unwrappedViewModel,
                        showCameraOnAppear: showCameraOnAppear,
                        onDismiss: { viewModel.wrappedValue = nil })
                }
            }
    }
    
    func addToPantryPopup(isPresented: Binding<Bool>, viewModel: AddToPantryViewModel, showCameraOnAppear: Bool) -> some View {
        self
            .fullScreenCover(isPresented: isPresented) {
                NavigationStack {
                    AddToPantryView(
                        viewModel: viewModel,
                        showCameraOnAppear: showCameraOnAppear,
                        onDismiss: { isPresented.wrappedValue = false })
                }
            }
    }
    
}

#Preview {
    
    NavigationStack {
        AddToPantryView(
            viewModel: AddToPantryViewModel(),
            showCameraOnAppear: false,
//            onUseManualEntry: {
//                
//            },
            onDismiss: {
                
            }
        )
    }
    
}
