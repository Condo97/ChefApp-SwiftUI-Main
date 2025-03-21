//
//  RecipeEditableIngredientView.swift
//  Barback
//
//  Created by Alex Coundouriotis on 10/2/23.
//

import SwiftUI

struct RecipeEditableIngredientView: View {
    
    @State var measuredIngredient: RecipeMeasuredIngredient
//    @Binding var expandedPercentage: CGFloat
    @Binding var isExpanded: Bool
    @Binding var isDisabled: Bool
    var onEdit: () -> Void
    
    @Environment(\.managedObjectContext) private var viewContext
    
    private let lowerBound = 0.25
    private let upperBound = 0.75
    
    @State private var parsedMeasuredIngredient: MeasurementIngredientParser.ParsedMeasurementIngredient?
    
    init(measuredIngredient: RecipeMeasuredIngredient, isExpanded: Binding<Bool>, isDisabled: Binding<Bool>, onEdit: @escaping () -> Void) {
        self._measuredIngredient = State(initialValue: measuredIngredient)
        self._isExpanded = isExpanded
        self._isDisabled = isDisabled
        self.onEdit = onEdit
        self._parsedMeasuredIngredient = State(initialValue: MeasurementIngredientParser.parseFirstMeasurement(from: measuredIngredient.nameAndAmountModified ?? measuredIngredient.nameAndAmount ?? "", leastToGreatestPossibleFractionValues: MeasuredIngredientPickerView.defaultMinToMaxFractionStrings))
    }
    
//    private var isDisabledByScrolling: Bool {
//        expandedPercentage < upperBound
//    }
    
    private var backgroundFillColor: Color {
        if measuredIngredient.markedForDeletion {
            return Color(uiColor: .systemRed)
        }
        if measuredIngredient.nameAndAmountModified != nil, measuredIngredient.nameAndAmountModified != measuredIngredient.nameAndAmount {
            return Color(uiColor: .systemYellow)
        }
        return Colors.background
    }
    
//    private var buttonFillOpacity: CGFloat {
//        guard !isDisabled else {
//            return lowerBound
//        }
//        if expandedPercentage >= upperBound {
//            return 1.0
//        } else if expandedPercentage <= lowerBound {
//            return 0.0
//        } else {
//            return (expandedPercentage - lowerBound) * (1.0 / (upperBound - lowerBound))
//        }
//    }
    
//    private var textOpacity: CGFloat {
//        max(buttonFillOpacity, 0.5)
//    }
    
    var body: some View {
        ZStack {
//            let _ = Self._printChanges()
            Button(action: {
                HapticHelper.doLightHaptic()
                
                onEdit()
            }) {
                HStack(spacing: 6.0) {
                    Text(Image(systemName: "circle.fill"))
                        .font(.body, 2.0)
                        .foregroundStyle(Colors.foregroundText)
                    if let parsedMeasuredIngredient = parsedMeasuredIngredient {
                        if let amount = parsedMeasuredIngredient.amount {
                            Text(amount)
                                .font(.custom(Constants.FontName.heavy, size: 14.0))
                                .foregroundStyle(Colors.foregroundText)
                        }
                        if let fraction = parsedMeasuredIngredient.fraction {
                            Text(fraction)
                                .font(.custom(Constants.FontName.heavy, size: 14.0))
                                .foregroundStyle(Colors.foregroundText)
                        }
                        Text(parsedMeasuredIngredient.abbreviatedMeasurementArray[parsedMeasuredIngredient.abbreviatedMeasurementIndex].abbreviation)
                            .font(.custom(Constants.FontName.heavy, size: 14.0))
                            .foregroundStyle(Colors.foregroundText)
                        Text(parsedMeasuredIngredient.ingredient)
                            .font(.custom(Constants.FontName.body, size: 14.0))
                            .foregroundStyle(Colors.foregroundText)
                            .multilineTextAlignment(.leading)
                    } else {
                        Text(LocalizedStringKey(measuredIngredient.nameAndAmountModified ?? measuredIngredient.nameAndAmount ?? ""))
                            .font(.custom(Constants.FontName.body, size: 14.0))
                            .foregroundStyle(Colors.foregroundText)
                            .multilineTextAlignment(.leading)
                    }
                }
//                .opacity(isExpanded ? 1.0 : 0.5)
                .padding(.vertical, isExpanded ? 6.0 : 0.0)
                .padding(.horizontal)
                .background(
                    RoundedRectangle(cornerRadius: 28.0)
                        .fill(backgroundFillColor)
                        .opacity(isExpanded ? 1.0 : 0.0)
                )
            }
            .disabled(isDisabled || !isExpanded)
        }
        .onChange(of: measuredIngredient.nameAndAmount) { _ in
            parsedMeasuredIngredient = MeasurementIngredientParser.parseFirstMeasurement(from: measuredIngredient.nameAndAmountModified ?? measuredIngredient.nameAndAmount ?? "", leastToGreatestPossibleFractionValues: MeasuredIngredientPickerView.defaultMinToMaxFractionStrings)
        }
        .onChange(of: measuredIngredient.nameAndAmountModified) { _ in
            parsedMeasuredIngredient = MeasurementIngredientParser.parseFirstMeasurement(from: measuredIngredient.nameAndAmountModified ?? measuredIngredient.nameAndAmount ?? "", leastToGreatestPossibleFractionValues: MeasuredIngredientPickerView.defaultMinToMaxFractionStrings)
        }
    }
    
}

@available(iOS 17.0, *)
#Preview(traits: .sizeThatFitsLayout) {
    let context = CDClient.mainManagedObjectContext
    
    let measuredIngredient = RecipeMeasuredIngredient(context: context)
    measuredIngredient.nameAndAmount = "Name and Amount"
    
    try! context.save()
    
    return RecipeEditableIngredientView(
        measuredIngredient: measuredIngredient,
        isExpanded: .constant(true),
        isDisabled: .constant(false),
        onEdit: {
            
        }
    )
    .environment(\.managedObjectContext, CDClient.mainManagedObjectContext)
//        .environmentObject(PremiumUpdater())
//      .environmentObject(ProductUpdater())
//          .environmentObject(RemainingUpdater())
}
