//
//  EditPantryItemView.swift
//  Barback
//
//  Created by Alex Coundouriotis on 9/29/23.
//

import SwiftUI

struct EditPantryItemView: View {
    
    @State var pantryItem: PantryItem
    @Binding var isActive: Bool
//    @Binding var alertShowingHasChanges: Bool
    
    
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.colorScheme) private var colorScheme
    
    @State private var isSaving: Bool = false
    
    @State private var updatedNameText: String = ""
    @State private var updatedCategoryText: String = ""
//    @State private var updatedAmountText: String = ""
//    @State private var updatedExpirationDate: Date = Date()
    
    @State private var alertShowingEmptyNameField: Bool = false
    @State private var alertShowingErrorSaving: Bool = false
    @State private var alertShowingShouldSave: Bool = false
    @State private var alertShowingDeleteItem: Bool = false
    @State private var alertShowingDuplicateItem: Bool = false
    
//    init(pantryItem: PantryItem, isActive: Binding<Bool>) {
//        self._item = StateObject(wrappedValue: pantryItem)
//        self._isActive = isActive
//        
//        self.originalNameText = pantryItem.name ?? ""
//        self.originalCategoryText = pantryItem.category ?? ""
//    }
    
    var body: some View {
        ZStack {
            VStack {
                header
                    .padding(.bottom, 8)
                
                nameView
                    .padding(.bottom, 8)
                
                categoryView
                    .padding(.bottom, 8)
                
//                amountView
//                    .padding(.bottom, 8)
//                
//                expirationDateView
//                    .padding(.bottom, 8)
                
                HStack {
                    Button(action: {
                        HapticHelper.doWarningHaptic()
                        
                        alertShowingDeleteItem = true
                    }) {
                        Image(systemName: "trash")
                            .aspectRatio(contentMode: .fit)
                            .foregroundStyle(Color(uiColor: .systemRed))
                            .padding()
                            .background(RoundedRectangle(cornerRadius: 20.0)
                                .stroke(lineWidth: 2.0)
                                .tint(Color(uiColor: .systemRed)))
                    }
                    .opacity(isSaving ? 0.4 : 1.0)
                    .disabled(isSaving)
                    
                    Button(action: {
                        HapticHelper.doSuccessHaptic()
                        
                        saveAndDismissEditing()
                    }) {
                        HStack {
                            Spacer()
                            Text("Save")
                                .foregroundStyle(Colors.elementText)
                            Spacer()
                        }
                        .padding()
                        .background(Colors.elementBackground)
                        .clipShape(RoundedRectangle(cornerRadius: 20.0))
                    }
                    .opacity(isSaving ? 0.4 : 1.0)
                    .disabled(isSaving)
                }
            }
        }
        .onAppear {
            // Update name, category, amount, and expiration date initial values from pantryItem
            if let name = pantryItem.name {
                updatedNameText = name
            }
            
            if let category = pantryItem.category {
                updatedCategoryText = category
            }
            
//            if let amount = pantryItem.amount {
//                updatedAmountText = amount
//            }
//            
//            if let expirationDate = pantryItem.expiration {
//                updatedExpirationDate = expirationDate
//            }
        }
        .alert("Missing Name", isPresented: $alertShowingEmptyNameField) {
            Button("Close", action: {
                
            })
        } message: {
            Text("Please make sure there the pantry item has at least a name.")
        }
        .alert("Delete Item", isPresented: $alertShowingDeleteItem, actions: {
            Button("Cancel", role: .cancel, action: {
                
            })
            
            Button("Delete", role: .destructive, action: {
                deleteAndDismissEditing()
            })
        }, message: {
            Text("Are you sure you want to delete this item?")
        })
        .alert("Duplicate Item", isPresented: $alertShowingDuplicateItem, actions: {
            Button("Close", role: .cancel, action: {
                
            })
        }, message: {
            Text("You have an item with this title already. Please choose a new title.")
        })
    }
    
    var header: some View {
        HStack {
            Text("Edit Item")
                .font(.custom(Constants.FontName.black, size: 28.0))
                .foregroundStyle(Colors.foregroundText)
            Spacer()
            Button(action: {
                HapticHelper.doLightHaptic()
                
                withAnimation {
                    isActive = false
                }
            }) {
                Text(Image(systemName: "xmark"))
                    .font(.custom(Constants.FontName.black, size: 24.0))
                    .foregroundStyle(Colors.foregroundText)
            }
        }
    }
    
    var nameView: some View {
        VStack {
            HStack {
                Text("Title*:")
                    .font(.custom(Constants.FontName.body, size: 17.0))
                Spacer()
            }
            .frame(minHeight: 0)
            
            TextField(
                text: $updatedNameText,
                prompt: Text(pantryItem.name ?? "Title")) {}
                .textFieldTickerTint(colorScheme == .light ? Colors.elementBackground : Colors.foregroundText)
                .keyboardDismissingTextFieldToolbar("Done", color: Colors.elementBackground)
                .padding([.leading, .trailing])
                .padding([.top, .bottom], 8)
                .background(Colors.foreground)
                .clipShape(RoundedRectangle(cornerRadius: 14.0))
        }
    }
    
    var categoryView: some View {
        VStack {
            // TODO: Should categories be able to be updated with the keyboard? Probably not, so pull in the categories and put it in a selector or something for the user to pick
            HStack {
                Text("Category:")
                    .font(.custom(Constants.FontName.body, size: 17.0))
                Text("(Optional)")
                    .font(.custom(Constants.FontName.lightOblique, size: 14.0))
                Spacer()
            }
            .frame(minHeight: 0)
            
            TextField(
                text: $updatedCategoryText,
                prompt: Text(pantryItem.category ?? "Category Name")) {}
                .textFieldTickerTint(colorScheme == .light ? Colors.elementBackground : Colors.foregroundText)
                .keyboardDismissingTextFieldToolbar("Done", color: Colors.elementBackground)
                .padding([.leading, .trailing])
                .padding([.top, .bottom], 8)
                .background(Colors.foreground)
                .clipShape(RoundedRectangle(cornerRadius: 14.0))
        }
    }
    
//    var amountView: some View {
//        // TODO: This should be a picker with all the categories listed so that the user can pick from the categories
//        VStack {
//            HStack {
//                Text("Amount:")
//                    .font(.custom(Constants.FontName.body, size: 17.0))
//                Text("(Optional)")
//                    .font(.custom(Constants.FontName.lightOblique, size: 14.0))
//                Spacer()
//            }
//            .frame(minHeight: 0)
//            
//            TextField(
//                text: $updatedAmountText,
//                prompt: Text("Amount of Item")) {}
//                .textFieldTickerTint(colorScheme == .light ? Colors.elementBackground : Colors.foregroundText)
//                .keyboardDismissingTextFieldToolbar("Done", color: Colors.elementBackground)
//                .font(.custom(Constants.FontName.body, size: 14.0))
//                .padding([.leading, .trailing])
//                .padding([.top, .bottom], 8)
//                .background(Colors.foreground)
//                .clipShape(RoundedRectangle(cornerRadius: 14.0))
//            
//            HStack {
//                Text("The amount you have of this item. ex. 2, 3 ml, 5 oz, etc.") // TODO: This should be a picker! Also this text should be changed for the picker potentially
//                    .multilineTextAlignment(.leading)
//                    .font(.custom(Constants.FontName.body, size: 12.0))
//                    .foregroundStyle(Colors.foregroundText)
//                    .opacity(0.6)
//                Spacer()
//            }
//        }
//    }
//    
//    var expirationDateView: some View {
//        VStack {
//            HStack {
//                Text("Expiration Date:")
//                    .font(.custom(Constants.FontName.body, size: 17.0))
//                Text("(Optional)")
//                    .font(.custom(Constants.FontName.lightOblique, size: 14.0))
//                Spacer()
//            }
//            .frame(minHeight: 0)
//            
//            DatePicker("Select Expiration Date", selection: $updatedExpirationDate, displayedComponents: [.date] )
//                .datePickerStyle(WheelDatePickerStyle())
//                .frame(height: 80.0)
//                .padding()
//            
//            HStack {
//                Text("The amount you have of this pantryItem. ex. 2, 3 ml, 5 oz, etc.") // TODO: This should be a picker! Also this text should be changed for the picker potentially
//                    .multilineTextAlignment(.leading)
//                    .font(.custom(Constants.FontName.body, size: 12.0))
//                    .foregroundStyle(Colors.foregroundText)
//                    .opacity(0.6)
//                Spacer()
//            }
//        }
//    }
    
    func deleteAndDismissEditing() {
        viewContext.delete(pantryItem)
        
        saveAndDismissEditing()
    }
    
    func discardAndDismissEditing() {
        viewContext.rollback()
        
        withAnimation {
            isActive = false
        }
    }
    
    func saveAndDismissEditing() {
        guard !updatedNameText.isEmpty else {
            alertShowingEmptyNameField = true
            return
        }
        
        Task {
            // Check for duplicates
            let fetchRequest = PantryItem.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "%K = %@", #keyPath(PantryItem.name), updatedNameText)
            guard try await CDClient.count(fetchRequest: fetchRequest, in: viewContext) <= 1 else {
                // TODO: Handle errors for duplication!
                print("Duplicate found and not saved in appendPantryItem!")
                await MainActor.run {
                    alertShowingDuplicateItem = true
                }
                return
            }
            
            // Update pantryItem values and save and set isActive to false
            do {
                try await viewContext.perform {
                    pantryItem.name = updatedNameText
                    pantryItem.category = updatedCategoryText
//                    pantryItem.amount = updatedAmountText
//                    pantryItem.expiration = updatedExpirationDate
                    
                    pantryItem.updateDate = Date()
                    
                    try viewContext.save()
                }
                
                withAnimation {
                    isActive = false
                }
            } catch {
                // TODO: Handle errors
                print("Error saving and setting values in PantryItemsListRowView... \(error)")
                await MainActor.run {
                    alertShowingErrorSaving = true
                }
            }
        }
    }
    
    func setAndSaveValues() throws {
        
        try viewContext.save()
    }
    
    
}

extension View {
    
    func editPantryItemPopup(isPresented: Binding<Bool>, pantryItem: PantryItem) -> some View {
        self
            .clearFullScreenCover(isPresented: isPresented) {
                EditPantryItemView(pantryItem: pantryItem, isActive: isPresented)
                    .padding()
                    .background(Colors.foreground)
                    .clipShape(RoundedRectangle(cornerRadius: 14.0))
                    .padding()
            }
    }
    
    func editPantryItemPopup(pantryItem: Binding<PantryItem?>) -> some View {
        var isPresented: Binding<Bool> {
            Binding(
                get: {
                    pantryItem.wrappedValue != nil
                },
                set: { value in
                    if !value {
                        pantryItem.wrappedValue = nil
                    }
                })
        }
        
        return self
            .clearFullScreenCover(isPresented: isPresented) {
                if let pantryItemWrappedValue = pantryItem.wrappedValue {
                    EditPantryItemView(pantryItem: pantryItemWrappedValue, isActive: isPresented)
                        .padding()
                        .background(Colors.foreground)
                        .clipShape(RoundedRectangle(cornerRadius: 14.0))
                        .padding()
                }
            }
    }
    
}

@available(iOS 17, *)
#Preview(traits: .sizeThatFitsLayout) {
    let pantryItem = PantryItem(context: CDClient.mainManagedObjectContext)
    
    pantryItem.name = "adsfasdf"
    pantryItem.category = "there should be better categories maybe an enum lol"
    
    try! CDClient.mainManagedObjectContext.save()
    
    return EditPantryItemView(
        pantryItem: pantryItem,
        isActive: .constant(true))
        .padding()
        .background(Colors.foreground)
        .clipShape(RoundedRectangle(cornerRadius: 28.0))
        .environment(\.managedObjectContext, CDClient.mainManagedObjectContext)
        .environmentObject(PremiumUpdater())
        .environmentObject(ProductUpdater())
        .environmentObject(RemainingUpdater())
}
