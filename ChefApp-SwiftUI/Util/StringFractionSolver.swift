//
//  StringFractionSolver.swift
//  PantryPal
//
//  Created by Alex Coundouriotis on 7/18/23.
//

import Foundation

class StringFractionSolver {
    
    static func solveFraction(from string: String) -> Double? {
        // Check if it's a fraction and set solvedDoubleValue to solved fraction
        let forwardSlashSplitFirstAmountString = string.split(separator: "/")
        
        // Ensure forwardSlashSplitFirstAmountString has exactly two values, otherwise return nil
        guard forwardSlashSplitFirstAmountString.count == 2 else {
            return nil
        }
        
        // Unwrap numerator and denomenator as doubles, otherwise return nil
        guard let numerator = Double(String(forwardSlashSplitFirstAmountString[0])), let denomenator = Double(String(forwardSlashSplitFirstAmountString[1])) else {
            return nil
        }
        
        // Solve fraction and set to solvedDoubleValue
        return numerator / denomenator
    }
    
}
