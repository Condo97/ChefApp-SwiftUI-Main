////
////  IngredientMeasurementAmountParser.swift
////  Barback
////
////  Created by Alex Coundouriotis on 10/3/23.
////
//
//import Foundation
//
//class IngredientMeasurementAmountParser {
//    
//    struct ParsedMeasurementAmount {
//        var amount: String?
//        var fraction: String?
//        var abbreviatedMeasurementArray: [AbbreviatedMeasurement]
//        var abbreviatedMeasurementIndex: Int
//    }
//    
//    static func parseFirstMeasurement(from string: String, leastToGreatestPossibleFractionValues: [String]) -> ParsedMeasurementAmount? {
//        for abbreviatedMeasurementArray in Measurements.allOrderedMeasurements {
//            for i in 0..<abbreviatedMeasurementArray.count {
//                // Get abbreviatedMeasurement
//                let abbreviatedMeasurement = abbreviatedMeasurementArray[i]
//                
//                // Loop through abbreviation and alternatives for abbreviatedMeasurement
//                for j in 0..<(1 + abbreviatedMeasurement.alternatives.count) {
//                    // Get measurementString
//                    let measurementString = j == 0 ? abbreviatedMeasurement.abbreviation : abbreviatedMeasurement.alternatives[j - 1]
//                    
//                    // Create regular expression pattern..
//                    // Right now it is different than below, and it will match any number with or without decimal and or fraction followed by any amount of whitespace and measurementString
////                    - `\\b`: This is a word boundary. This ensures that the match will not be part of a larger word.
////                    - `(?<amount>\\d+(?:\\.\\d+)?(?:\\s+\\d+\\/\\d+)?)?`: This is an optional named group (called "amount") that matches amounts with the following pattern `numbers , ( decimal numbers or fractional numbers)`. Numbers can be decimal or fractional as follows:
////                      - `\\d+`: Match one or more digits.
////                      - `(?:\\.\\d+)?`: Non-capturing group (due to `?:`) to optionally match a decimal number i.e `.and any number of digits afterwards`.
////                      - `(?:\\s+\\d+\\/\\d+)?`: Non-capturing group (due to `?:`) to optionally match a fraction number `i.e space, digits , slash '/' , digits`
////                    - `\\s*`: Match zero or more whitespace characters.
////                    - `(?<unit>\\w+)?`: This is an optional named group (called "unit") that matches one or more word characters.
////                    - `\\s*`: Match zero or more whitespace characters.
////                    - `(?<ingredient>.*)?`: This is another optional named group (called "ingredient") that matches any character (.) zero or more times (*), i.e., it will match whatever is left in the string after matching the amount and unit.
////                    - `\\b`: This is again a word boundary.
////                    let pattern = "\\b\\d+(\\.\\d+)?+\\s+\\b\(measurementString)\\b"
////                    let pattern = "(\\d+(\\.\\d+)?\\s*)(\\d+/\\d+\\s*)?(\(measurementString)\\b)"
////                    let pattern = "\\b(?<amount>\\d+(?:\\.\\d+)?(?:\\s+\\d+\\/\\d+)?)?(?:\\s*(?<unit>\\w+))?(?:\\s*(?<ingredient>.*))?\\b"
//                    /* Get Number and Fraction Strings */
//                    let amountName = "amount"
////                    let amountMeasurementPattern = "\\b(?<\(amountName)>\\d+(?:\.\\d+)?(?:\\s+\\d+\\/\\d+)?)\\s+\\b\(measurementString)\\b"
//                    let amountMeasurementPattern = "\\b(?<\(amountName)>(?:\\d+)?(?:\\.\\d+)?((?:\\d\\s+)?(?:\\d+\\/\\d+))?)\\s+\\b\(measurementString)\\b"
//                    
//                    // Create regular expression with the option of caseInsensitive to search for matching string regardless of case
//                    let amountMeasurementRegex = try? NSRegularExpression(pattern: amountMeasurementPattern, options: .caseInsensitive)
//                    
//                    // Get the first match and unwrap, otherwise continue TODO: Maybe the measurement thing support multiple matches.. is that even necessary?
//                    guard let amountMeasurementFirstMatch = amountMeasurementRegex?.firstMatch(in: string, range: NSRange(location: 0, length: string.utf16.count)) else {
//                        continue
//                    }
//                    
//                    // Get the amountString from amount in firstMatch
//                    let amountNSRange = amountMeasurementFirstMatch.range(withName: amountName)
//                    guard amountNSRange.location != NSNotFound, let amountRange = Range(amountNSRange, in: string) else {
//                        continue
//                    }
//                    let amountString = String(string[amountRange])
//                    
//                    // Parse amountString into amount number and fraction
////                    let numberName = "number"
////                    let fractionName = "fraction"
////                    let amountNumberFractionPattern = "\\b(?<\(numberName)>\\d+(?:.\\d+)?)?(?:(?<\(fractionName)>\\s+\\d+\\/\\d+)?)"
//                    
//                    // Create regular expression with the option of caseInsensitive to serach for matching string regardless of case, even though its numbers here I guess lol
////                    let amountNumberFractionRegex = try? NSRegularExpression(pattern: amountNumberFractionPattern, options: .caseInsensitive)
//                    
//                    // Get the first match and unwrap, otherwise continue
////                    guard let amountNumberFractionFirstMatch = amountNumberFractionRegex?.firstMatch(in: amountString, range: NSRange(location: 0, length: amountString.utf16.count)) else {
////                        continue
////                    }
//                    
//                    
//                    
//                    // Will always be in the format 1, 1.5, 1/2, or 1 1/2
//                    // So split by spaces, we get (1), (1.5), (1/2), (1, 1/2)
//                    // If the first is a double, get its fraction
//                    
//                    // Split amountString by space
//                    let spaceSplitAmountString = amountString.split(separator: " ")
//                    
//                    // Ensure spaceString has at least one and no more than 2 values, otherwise continue
//                    guard spaceSplitAmountString.count > 0 && spaceSplitAmountString.count <= 2 else {
//                        continue
//                    }
//                    
//                    // Get the numberString and fractionString
//                    var numberString: String? = nil, fractionString: String? = nil
//                    if let intValue = Int(String(spaceSplitAmountString[0])) {
//                        // If it's an int, set the numberString as an int
//                        numberString = "\(intValue)"
//                        
//                        // Get the fraction if there is one
//                        if spaceSplitAmountString.count == 2, let solvedFractionFromSecondAmountString = StringFractionSolver.solveFraction(from: String(spaceSplitAmountString[1])) {
//                            // Set fractionString to the result of getFractionString from DecimalToFractionStringAdapter
//                            fractionString = DecimalToFractionStringAdapter.getFractionString(from: solvedFractionFromSecondAmountString, leastToGreatestPossibleValues: leastToGreatestPossibleFractionValues)
//                        }
//                    } else {
//                        // Ensure the count of spaceSplitAmountString is 1 before proceeding, otherwise continue, as there should only be one double or a fraction by itself or with a whole number
//                        guard spaceSplitAmountString.count == 1 else {
//                            continue
//                        }
//                        
//                        // TODO: If first number is a double or fraction and there is a second number, continue
//                        // Not a int, check if it is a double or fraction, setting doubleValue with the double or solved fraction equation, otherwise continue
//                        let solvedDoubleValue: Double
//                        if let doubleValue = Double(String(spaceSplitAmountString[0])) {
//                            // Got double, so set solvedDoubleValue to doubleValue
//                            solvedDoubleValue = doubleValue
//                        } else {
//                            // Solve fraction and set to solvedDoubleValue, otherwise continue
//                            guard let solvedFractionFromFirstAmountString = StringFractionSolver.solveFraction(from: String(spaceSplitAmountString[0])) else {
//                                continue
//                            }
//                            solvedDoubleValue = solvedFractionFromFirstAmountString
//                        }
//                        
//                        // numberString is the Int value of solvedDoubleValue
//                        numberString = String(Int(solvedDoubleValue))
//                        
//                        // fractionString is the result of getFractionString from DecimalToFractionStringAdapter
//                        fractionString = DecimalToFractionStringAdapter.getFractionString(from: solvedDoubleValue, leastToGreatestPossibleValues: leastToGreatestPossibleFractionValues)
//                        
//                        // If numberString is 0 and there is a fraction, set numberString to nil
//                        if fractionString != nil, numberString != nil, let numberStringInt = Int(numberString!), numberStringInt == 0 {
//                            numberString = nil
//                        }
//                    }
//                    
//                    
//                    
////                    let numberNSRange = amountNumberFractionFirstMatch.range(withName: numberName)
////                    let fractionNSRange = amountNumberFractionFirstMatch.range(withName: fractionName)
////                    if numberNSRange.location != NSNotFound, let numberRange = Range(numberNSRange, in: amountString) {
////                        numberString = String(amountString[numberRange]).trimmingCharacters(in: .whitespaces)
////                    }
////                    if fractionNSRange.location != NSNotFound, let fractionRange = Range(fractionNSRange, in: amountString) {
////                        fractionString = String(amountString[fractionRange]).trimmingCharacters(in: .whitespaces)
////                    }
//                    
//                    /* Get Ingredient */
//                    // Get and unwrap amount measurement measurement range in string from amountMeasurementFirstMatch range, otherwise continue
//                    guard let amountMeasurementRangeInString = Range(amountMeasurementFirstMatch.range, in: string) else {
//                        continue
//                    }
//                    
////                    // Get ingredient from string if range location is 0 or range location + range length is the length of the string and get measurementOnLeft depending on if the measurement is on the left side of the string, otherwise return TODO: How would I convert these to using the measurementRangeInString?
////                    let ingredient: String
////                    let measurementOnLeft: Bool
////                    if amountMeasurementFirstMatch.range.location == 0 {
////                        // If measurement is at the beginning of the string, set ingredient to everything after the range
////                        ingredient = String(string[amountMeasurementRangeInString.upperBound...]).trimmingCharacters(in: .whitespaces)
////                        measurementOnLeft = true
////                    } else if amountMeasurementFirstMatch.range.location + amountMeasurementFirstMatch.range.length == string.count {
////                        // If measurement is at the end of the string, set ingredient to everything before the range
////                        ingredient = String(string[..<amountMeasurementRangeInString.lowerBound]).trimmingCharacters(in: .whitespaces)
////                        measurementOnLeft = false
////                    } else {
////                        // First match is not at the beginning or end of the string, so continue TODO: Maybe allow for more flexibility?
////                        continue
////                    }
////                    
////                    // Get measurement from string
////                    let measurement = String(string[measurementRangeInString])
////
////                    // Parse the number out of the measurement string, continuing if any optionals fail to unwrap
////                    let numberPattern = "\\d+(\\.\\d+)?"
////                    let numberRegex = try? NSRegularExpression(pattern: numberPattern)
////                    guard let numberFirstMatch = numberRegex?.firstMatch(in: measurement, range: NSRange(location: 0, length: measurement.utf16.count)), let numberRange = Range(numberFirstMatch.range, in: measurement) else {
////                        continue
////                    }
////                    guard let amount = Double(String(measurement[numberRange])) else {
////                        continue
////                    }
//                    
//                    // Return ParsedMeasurementIngredient with amount, abbreviatedMeasurementArray, index of abbreviated measurement i, ingredient string, and if the measurement is on the left side
//                    return ParsedMeasurementAmount(
//                        amount: numberString,
//                        fraction: fractionString,
//                        abbreviatedMeasurementArray: abbreviatedMeasurementArray,
//                        abbreviatedMeasurementIndex: i)
//                }
//            }
//        }
//        
//        return nil
//        
//    }
//    
//}
