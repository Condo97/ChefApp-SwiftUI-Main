//
//  RecipeIngredientEditorView.swift
//  Barback
//
//  Created by Alex Coundouriotis on 10/2/23.
//

import SwiftUI

struct RecipeIngredientEditorView: View {
    
    @State var measuredIngredient: RecipeMeasuredIngredient
    @Binding var isShowing: Bool
    
    
    @Environment(\.managedObjectContext) var viewContext
    @Environment(\.colorScheme) private var colorScheme
    
    let testList: [String] = [
        "asdf",
        "asdf2",
        "asdf3"
    ]
    
    @State private var usingFormattedEditor: Bool = false
    
    @State private var newAmount: String
    @State private var newFraction: String
    @State private var newAbbreviatedMeasurement: AbbreviatedMeasurement
    
    @State private var newMeasurement: String
    
    @State private var newIngredient: String
    
    @State private var alertShowingDeleteEmpty: Bool = false
    @State private var alertShowingHasChangesToSave: Bool = false
    @State private var alertShowingRevertIngredient: Bool = false
    
    var formattedMeasurement: String {
        if usingFormattedEditor {
            var measurement = ""
            if !newAmount.isEmpty {
                measurement += newAmount
                measurement += " "
            }
            
            if !newFraction.isEmpty {
                measurement += newFraction
                measurement += " "
            }
            
            if newAbbreviatedMeasurement != Measurements.blankAbbreviatedMeasurement {
                measurement += newAbbreviatedMeasurement.abbreviation
                measurement += " "
            }
            
            return measurement.trimmingCharacters(in: .whitespaces)
        } else {
            return newMeasurement.trimmingCharacters(in: .whitespaces)
        }
    }
    
    var formattedIngredient: String {
        newIngredient.trimmingCharacters(in: .whitespaces)
    }
    
    var finalizedMeasuredIngredient: String {
        (formattedMeasurement.isEmpty ? "" : formattedMeasurement + " ") + (formattedIngredient.isEmpty ? "" : formattedIngredient)
    }
    
    var hasChanges: Bool {
//        (measuredIngredient.measurementModified != formattedMeasurement && measuredIngredient.measurement != formattedMeasurement) || (measuredIngredient.ingredientModified != formattedIngredient && measuredIngredient.ingredient != formattedIngredient)
        print(measuredIngredient.nameAndAmountModified ?? "empty")
        print(formattedIngredient)
        return measuredIngredient.nameAndAmountModified ?? measuredIngredient.nameAndAmount ?? "" != finalizedMeasuredIngredient
//        return measuredIngredient.measurementModified ?? measuredIngredient.measurement ?? "" != formattedMeasurement || measuredIngredient.ingredientModified ?? measuredIngredient.ingredient ?? "" != formattedIngredient
    }
    
    init(measuredIngredient: RecipeMeasuredIngredient, isShowing: Binding<Bool>) {
        self._measuredIngredient = State(initialValue: measuredIngredient)
        self._isShowing = isShowing
        
        // Parse measurement and ingredient
        if let measurementAndIngredient = measuredIngredient.nameAndAmountModified ?? measuredIngredient.nameAndAmount {
            if let parsedMeasuredIngredient = MeasurementIngredientParser.parseFirstMeasurement(from: measurementAndIngredient, leastToGreatestPossibleFractionValues: MeasuredIngredientPickerView.defaultMinToMaxFractionStrings) {
                // If using formatted editor
                _newIngredient = State(initialValue: parsedMeasuredIngredient.ingredient)
                _newAmount = State(initialValue: parsedMeasuredIngredient.amount ?? "")
                _newFraction = State(initialValue: parsedMeasuredIngredient.fraction ?? "")
                _newAbbreviatedMeasurement = State(initialValue: parsedMeasuredIngredient.abbreviatedMeasurementArray[parsedMeasuredIngredient.abbreviatedMeasurementIndex]) // TODO: Is it a good idea to use safe here? Is there any reason to catch this not being in the array?
                _newMeasurement = State(initialValue: "")
                _usingFormattedEditor = State(initialValue: true)
            } else {
                // If not using formatted editor
                _newIngredient = State(initialValue: measurementAndIngredient)
                _newAmount = State(initialValue: "")
                _newFraction = State(initialValue: "")
                _newAbbreviatedMeasurement = State(initialValue: Measurements.blankAbbreviatedMeasurement)
                
                _newMeasurement = State(initialValue: "")
                
                _usingFormattedEditor = State(initialValue: false)
            }
        } else {
            // If cannot unwrap measurementAndIngredient
            _newIngredient = State(initialValue: "")
            _newAmount = State(initialValue: "")
            _newFraction = State(initialValue: "")
            _newAbbreviatedMeasurement = State(initialValue: Measurements.blankAbbreviatedMeasurement)
            
            _newMeasurement = State(initialValue: "")
            
            _usingFormattedEditor = State(initialValue: false)
        }
    }
    
    
    var body: some View {
        VStack {
            HStack {
                Text("Edit Ingredient")
                    .font(.custom(Constants.FontName.black, size: 24.0))
                Spacer()
                Button(action: {
                    HapticHelper.doLightHaptic()
                    
                    if hasChanges {
                        alertShowingHasChangesToSave = true
                    } else {
                        withAnimation {
                            do {
                                try self.saveNewValuesAndClose()
                            } catch {
                                // TODO: Handle Errors
                                print("Error saving new values and closing in RecipeIngredientEditorView... \(error)")
                            }
                        }
                    }
                }) {
                    Text(Image(systemName: "xmark"))
                        .font(.custom(Constants.FontName.black, size: 24.0))
                        .foregroundStyle(Colors.elementBackground)
                }
            }
            
            HStack(spacing: 4.0) {
                if usingFormattedEditor {
                    // Use newAmount, newFraction, and newAbbreviatedMeasurement if using formatted editor
                    ZStack {
                        MeasuredIngredientPickerView(
                            amount: $newAmount,
                            fraction: $newFraction,
                            abbreviatedMeasurement: $newAbbreviatedMeasurement)
                        .padding(.leading, -10)
                        .padding(.trailing, -5)
                    }
                } else {
//                    // Use measurement if not using formatted editor
//                    TextField("Measurement", text: $newMeasurement)
//                        .textFieldTickerTint(colorScheme == .light ? Colors.elementBackground : Colors.foregroundText)
//                        .keyboardDismissingTextFieldToolbar("Done", color: Colors.elementBackground)
//                        .font(.custom(Constants.FontName.body, size: 17.0))
//                        .frame(minHeight: 40)
//                        .frame(maxWidth: 200)
//                        .padding([.leading, .trailing])
//                        .padding([.top, .bottom], 8)
//                        .background(Colors.foreground)
//                        .clipShape(UnevenRoundedRectangle(cornerRadii: RectangleCornerRadii(topLeading: 14.0, bottomLeading: 14.0)))
//                        .fixedSize(horizontal: true, vertical: true)
                }
                
                // Ingredient is common
                TextField("Ingredient*", text: $newIngredient, axis: .vertical)
                    .textFieldTickerTint(colorScheme == .light ? Colors.elementBackground : Colors.foregroundText)
                    .keyboardDismissingTextFieldToolbar("Done", color: Colors.elementBackground)
                    .font(.custom(Constants.FontName.black, size: 17.0))
                    .frame(minHeight: 40)
                    .padding([.leading, .trailing])
                    .padding([.top, .bottom], 8)
                    .background(Colors.foreground)
                    .clipShape(usingFormattedEditor
                               ?
                               // Only round the right side if using formatted editor
                               UnevenRoundedRectangle(cornerRadii: RectangleCornerRadii(bottomTrailing: 14.0, topTrailing: 14.0))
                               :
                                // Round all sides if not using formatted editor since this is the only field used
                                UnevenRoundedRectangle(cornerRadii: RectangleCornerRadii(topLeading: 14.0, bottomLeading: 14.0, bottomTrailing: 14.0, topTrailing: 14.0)))
            }
            .padding(.bottom)
            
            HStack {
                Button(action: {
                    HapticHelper.doLightHaptic()
                    
                    markForDeletion()
                    
                    withAnimation {
                        isShowing = false
                    }
                }) {
                    Text(Image(systemName: "trash"))
                        .aspectRatio(contentMode: .fit)
                        .font(.custom(Constants.FontName.heavy, size: 20.0))
                        .foregroundStyle(Colors.elementText)
                        .fixedSize(horizontal: true, vertical: true)
                }
                .padding(8)
                .background(Color(uiColor: .systemRed))
                .clipShape(RoundedRectangle(cornerRadius: 14.0))
                
                Button(action: {
                    HapticHelper.doWarningHaptic()
                    
                    alertShowingRevertIngredient = true
                }) {
                    Text(Image(systemName: "clock.arrow.circlepath"))
                        .aspectRatio(contentMode: .fit)
                        .font(.custom(Constants.FontName.medium, size: 20.0))
                        .foregroundStyle(Colors.elementText)
                        .fixedSize(horizontal: true, vertical: true)
                }
                .padding(8)
                .background(Color(uiColor: .systemYellow))
                .clipShape(RoundedRectangle(cornerRadius: 14.0))
                
                Button(action: {
                    HapticHelper.doSuccessHaptic()
                    
                    do {
                        try saveNewValuesAndClose()
                    } catch {
                        // TODO: Handle Errors
                        print("Error saving new values and closing in RecipeIngredientEditorView... \(error)")
                    }
                }) {
                    Spacer()
                    Text(measuredIngredient.markedForDeletion ? "Restore & Save" : "Save")
                        .font(.custom(Constants.FontName.heavy, size: 20.0))
                        .foregroundStyle(Colors.elementText)
                    Spacer()
                }
                .padding(8)
                .background(Colors.elementBackground)
                .clipShape(RoundedRectangle(cornerRadius: 14.0))
            }
            .fixedSize(horizontal: false, vertical: true)
            
        }
        .alert("Empty Ingredient", isPresented: $alertShowingDeleteEmpty, actions: {
            Button("Cancel", role: .cancel, action: {
                
            })
            
            Button("Delete", role: .destructive, action: {
                // Delete measured ingredient from viewContext and save context
                do {
                    try viewContext.performAndWait {
                        viewContext.delete(measuredIngredient)
                        
                        try viewContext.save()
                    }
                } catch {
                    // TODO: Handle Errors
                    print("Error deleting measuredIngredient in RecipeIngredientEditorView... \(error)")
                }
                
                withAnimation {
                    isShowing = false
                }
            })
        }) {
            Text("Please ensure there is text in the \"Ingredient\" field before saving.")
        }
        .alert("Save Changes", isPresented: $alertShowingHasChangesToSave, actions: {
            Button("Save", role: nil, action: {
                do {
                    try saveNewValuesAndClose()
                } catch {
                    // TODO: Handle Errors
                    print("Error saving new values and closing in RecipeIngredientEditorView... \(error)")
                }
            })
            
            Button("Don't Save", role: .destructive, action: {
                withAnimation {
                    isShowing = false
                }
            })
            
            Button("Back", role: .cancel, action: {
                
            })
        }) {
            Text("You have unsaved changes to this ingredient. Save changes?")
        }
        .alert("Revert Ingredient", isPresented: $alertShowingRevertIngredient, actions: {
            Button("Revert", role: nil, action: {
                do {
                    try revertIngredientAndMeasurement()
                } catch {
                    // TODO: Handle Error, show alert or something
                    print("Error reverting ingredient in RecipeIngredientEditorView... \(error)")
                }
                
                withAnimation {
                    isShowing = false
                }
            })
            
            Button("Cancel", role: .cancel, action: {
                
            })
        }) {
            Text("Revert ingredient to its original value?")
        }
    }
    
    private func markForDeletion() {
        measuredIngredient.markedForDeletion = true
        
        saveContext()
    }
    
    private func revertIngredientAndMeasurement() throws {
        try viewContext.performAndWait {
            measuredIngredient.nameAndAmount = nil
            measuredIngredient.markedForDeletion = false
            
            try viewContext.save()
        }
    }
    
    private func saveNewValuesAndClose() throws {
        // Ensure ingredient is not empty, otherwise show delete empty alert
        guard !formattedIngredient.isEmpty else {
            alertShowingDeleteEmpty = true
            return
        }
        
        try viewContext.performAndWait {
            if usingFormattedEditor {
                // Set modified values, resetting if the new ones are the same as the original values and setting if they are different
                let formattedMeasurementAndIngredient = formattedMeasurement + " " + formattedIngredient
                if formattedMeasurementAndIngredient == measuredIngredient.nameAndAmount {
                    measuredIngredient.nameAndAmountModified = nil
                } else {
                    measuredIngredient.nameAndAmountModified = formattedMeasurementAndIngredient
                }
            } else {
                // Set modified values to just ingredient, resetting if the new ingredient is the same as nameAndAmount and setting if they are different
                if formattedIngredient == measuredIngredient.nameAndAmount {
                    measuredIngredient.nameAndAmountModified = nil
                } else {
                    measuredIngredient.nameAndAmountModified = formattedIngredient
                }
            }
            
            // Set as not marked for deletion
            measuredIngredient.markedForDeletion = false
            
            // Save context
            try viewContext.save()
            
            // Dismiss
            withAnimation {
                isShowing = false
            }
        }
    }
    
    private func saveContext() {
        do {
            try viewContext.save()
        } catch {
            // TODO: Handle errors
            print("Could not save context in RecipeIngredientEditorView... \(error)")
        }
    }
}

@available(iOS 17.0, *)
#Preview(traits: .sizeThatFitsLayout) {
    let context = PersistenceController.shared.container.viewContext
    
    let measuredIngredient = RecipeMeasuredIngredient(context: context)
    
    measuredIngredient.nameAndAmount = "22a cup Ingredient"
    
    try! context.save()
    
    return RecipeIngredientEditorView(
        measuredIngredient: measuredIngredient,
        isShowing: .constant(true))
    .padding()
    .background(Colors.background)
}
