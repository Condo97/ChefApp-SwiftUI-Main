//
//  Measurements.swift
//  Barback
//
//  Created by Alex Coundouriotis on 10/2/23.
//

import Foundation

struct Measurements {
    
    static let blankAbbreviatedMeasurement: AbbreviatedMeasurement = AbbreviatedMeasurement(
        abbreviation: "",
        alternatives: [])
    
    static let orderedMassMeasurements: [AbbreviatedMeasurement] = [
        AbbreviatedMeasurement(
            abbreviation: "g",
            alternatives: [
                "gram",
                "grams"
            ]),
        AbbreviatedMeasurement(
            abbreviation: "oz",
            alternatives: [
                "ounce",
                "ounces"
            ]),
        AbbreviatedMeasurement(
            abbreviation: "lb",
            alternatives: [
                "lbs",
                "pound",
                "pounds"
            ]),
        AbbreviatedMeasurement(
            abbreviation: "kg",
            alternatives: [
                "kgs",
                "kilogram",
                "kilograms"
            ])
    ]

    static let orderedLengthMeasurements: [AbbreviatedMeasurement] = [
        AbbreviatedMeasurement(
            abbreviation: "mm",
            alternatives: [
                "millimeter",
                "millimeters"
            ]),
        AbbreviatedMeasurement(
            abbreviation: "cm",
            alternatives: [
                "centimeter",
                "centimeters"
            ]),
        AbbreviatedMeasurement(
            abbreviation: "in",
            alternatives: [
                "inch",
                "inches"
            ]),
        AbbreviatedMeasurement(
            abbreviation: "ft",
            alternatives: [
                "foot",
                "feet"
            ]),
        AbbreviatedMeasurement(
            abbreviation: "yd",
            alternatives: [
                "yard",
                "yards"
            ])
    ]

    static let orderedVolumeMeasurements: [AbbreviatedMeasurement] = [
        AbbreviatedMeasurement(
            abbreviation: "ml",
            alternatives: [
                "milliliter",
                "milliliters"
            ]),
        AbbreviatedMeasurement(
            abbreviation: "tsp",
            alternatives: [
                "teaspoon",
                "teaspoons",
                "tsps"
            ]),
        AbbreviatedMeasurement(
            abbreviation: "tbsp",
            alternatives: [
                "tablespoon",
                "tablespoons",
                "tbsps"
            ]),
        AbbreviatedMeasurement(
            abbreviation: "fl oz",
            alternatives: [
                "fluid ounce",
                "fluid ounces"
            ]),
        AbbreviatedMeasurement(
            abbreviation: "cup",
            alternatives: [
                "cup",
                "cups"
            ]),
        AbbreviatedMeasurement(
            abbreviation: "pt",
            alternatives: [
                "pint",
                "pints"
            ]),
        AbbreviatedMeasurement(
            abbreviation: "qt",
            alternatives: [
                "quart",
                "quarts"
            ]),
        AbbreviatedMeasurement(
            abbreviation: "l",
            alternatives: [
                "litre",
                "litres",
                "liter",
                "liters"
            ]),
        AbbreviatedMeasurement(
            abbreviation: "gal",
            alternatives: [
                "gallon",
                "gallons"
            ])
    ]

    static let orderedTemperatureMeasurements: [AbbreviatedMeasurement] = [
        AbbreviatedMeasurement(
            abbreviation: "C",
            alternatives: [
                "C",
                "celsius"
            ]),
        AbbreviatedMeasurement(
            abbreviation: "F",
            alternatives: [
                "F",
                "fahrenheit"
            ])
    ]
    
    static let allOrderedMeasurements: [[AbbreviatedMeasurement]] = [
        orderedMassMeasurements,
        orderedLengthMeasurements,
        orderedVolumeMeasurements,
        orderedTemperatureMeasurements
    ]
    
}
