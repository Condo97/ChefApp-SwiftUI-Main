//
//  DecimalToFractionStringAdapter.swift
//  PantryPal
//
//  Created by Alex Coundouriotis on 7/18/23.
//

import Foundation

class DecimalToFractionStringAdapter {
    
    static func getFractionString(from decimalNumber: Double, leastToGreatestPossibleValues: [String]) -> String? {
        // Get decimal from decimalNumber % 1
        let decimal = decimalNumber.truncatingRemainder(dividingBy: 1)
        
        // Ensure decimal is not 0, otherwise return nil
        guard decimal != 0 else {
            return nil
        }
        
        // Finds the closest possible value as a string converted to a double to the decimal number and returns it
        var prevPossibleValueDouble: Double?
        for i in 0..<leastToGreatestPossibleValues.count {//possibleValue in leastToGreatestPossibleValues {
            // Unwrap possibleValueDouble or continue
            guard let possibleValueDouble = StringFractionSolver.solveFraction(from: leastToGreatestPossibleValues[i]) else {
                continue
            }
            
            // If i > 0 since the value at i - 1 is returned, prevPossibleValueDouble is not nil, and abs(prevPossibleValueDouble - decimalNumber) is less than abs(possibleValueDouble - decimalNumber), then the previous number is the closest number and the string at its index should be returned
            if let prevPossibleValueDouble = prevPossibleValueDouble, abs(prevPossibleValueDouble - decimal) < abs(possibleValueDouble - decimal) {
                return leastToGreatestPossibleValues[i - 1]
            }
            
            // Set prevPossibleValueDouble and prevPossibleValueIndex
            prevPossibleValueDouble = possibleValueDouble
        }
        
        // If the loop finishes without returning a fraction string, return the last fraction string in leastToGreatestPossibleValues
        return leastToGreatestPossibleValues.last
    }
    
}
