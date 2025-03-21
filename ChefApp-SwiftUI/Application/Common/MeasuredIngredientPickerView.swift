//
//  MeasuredIngredientPickerView.swift
//  ChefApp-SwiftUI
//
//  Created by Alex Coundouriotis on 6/22/24.
//

import SwiftUI

struct MeasuredIngredientPickerView: View {
    
    @Binding var amount: String
    @Binding var fraction: String
    @Binding var abbreviatedMeasurement: AbbreviatedMeasurement
    
    static let defaultMinToMaxFractionStrings: [String] = [
        "",
        "1/8",
        "1/4",
        "1/2",
        "5/8",
        "3/4",
        "7/8"
    ]
    
    var body: some View {
        HStack(spacing: -15.0) {
            Picker("Amount", selection: $amount) {
                ForEach(Array(0...999).map({String($0)}), id: \.self) { amount in
                    Text("\(amount == "0" ? "" : amount)")
                        .font(.custom(Constants.FontName.black, size: 20.0))
                }
            }
            .frame(width: 70)
            .fixedSize(horizontal: false, vertical: true)
            .pickerStyle(.inline)
            
            Picker("Fraction", selection: $fraction) {
                ForEach(MeasuredIngredientPickerView.defaultMinToMaxFractionStrings, id: \.self) { fraction in
                    Text("\(fraction)")
                        .font(.custom(Constants.FontName.black, size: 20.0))
                }
            }
            .frame(width: 70)
            .fixedSize(horizontal: false, vertical: true)
            .pickerStyle(.inline)
            
            Picker("Measurement", selection: $abbreviatedMeasurement) {
                let allMeasurements = [Measurements.blankAbbreviatedMeasurement] + Measurements.allOrderedMeasurements.flatMap({$0})
                ForEach(allMeasurements, id: \.self) { orderedMeasurement in
//                                ForEach(orderedMeasurements, id: \.self) { item in
                    Text(orderedMeasurement.abbreviation)
                        .font(.custom(Constants.FontName.black, size: 20.0))
//                                }
                    
                    
                }
            }
            .frame(width: 70)
            .pickerStyle(.inline)
        }
    }
    
}

#Preview {
    
    MeasuredIngredientPickerView(
        amount: .constant("1"),
        fraction: .constant("1/2"),
        abbreviatedMeasurement: .constant(AbbreviatedMeasurement(abbreviation: "in", alternatives: ["m"]))
    )
    
}
