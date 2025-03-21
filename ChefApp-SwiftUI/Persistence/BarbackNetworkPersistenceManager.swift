////
////  BarbackNetworkPersistanceManager.swift
////  Barback
////
////  Created by Alex Coundouriotis on 9/17/23.
////
//
//import CoreData
//import Foundation
//
//class BarbackNetworkPersistenceManager {
//    
//    public static func createSaveDrink(authToken: String, input: String, expandIngredientsMagnitude: Int, useAllGivenIngredients: Bool) async throws -> Int64 {
//        // Build cdRequest and get cdResponse from BarbackNetworkService
//        let cdRequest = CreateDrinkRequest(
//            authToken: authToken,
//            input: input,
//            expandIngredientsMagnitude: expandIngredientsMagnitude,
//            useAllGivenIngredients: useAllGivenIngredients)
//        
//        let cdResponse = try await BarbackNetworkService.createDrink(request: cdRequest)
//        
//        // Append drink
//        try await DrinkCDClient.appendDrink(
//            drinkID: cdResponse.body.drinkID,
//            input: cdResponse.body.input,
//            name: cdResponse.body.name,
//            summary: cdResponse.body.summary,
//            feasibility: cdResponse.body.feasibility,
//            tastiness: cdResponse.body.tastiness)
//        
//        // Get permanent object ID for drinkID
//        let drinkObjectID = try await DrinkCDClient.getDrinkPermanentID(drinkID: cdResponse.body.drinkID)
//        
//        // Append drink ingredients
//        for ingredient in cdResponse.body.ingredients {
//            try await DrinkCDClient.appendMeasuredIngredient(
//                to: drinkObjectID,
//                ingredient: ingredient,
//                measurement: nil)
//        }
//        
//        return cdResponse.body.drinkID
//    }
//    
//    public static func finalizeSaveDrink(authToken: String, drinkID: Int64) async throws {
//        // Build fdRequest and get fdResponse from BarbackNetworkService
//        let fdRequest = FinalizeDrinkRequest(
//            authToken: authToken,
//            drinkID: drinkID)
//
//        let fcResponse = try await BarbackNetworkService.finalizeDrink(request: fdRequest)
//        
//        // Get permanent drinkObjectID for drink with drinkID
//        let drinkObjectID = try await DrinkCDClient.getDrinkPermanentID(drinkID: drinkID)
//        
//        // Update estimatedServings, feasibility, and tastiness if each can be unwrapped
//        if let estimatedServings = fcResponse.body.estimatedServings, let estimatedServings = Int16(exactly: estimatedServings) {
//            try await DrinkCDClient.updateDrink(drinkObjectID, estimatedServings: estimatedServings)
//        }
//        if let feasibility = fcResponse.body.feasibility, let feasibility = Int16(exactly: feasibility) {
//            try await DrinkCDClient.updateDrink(drinkObjectID, feasibility: feasibility)
//        }
//        if let tastiness = fcResponse.body.tastiness, let tastiness = Int16(exactly: tastiness) {
//            try await DrinkCDClient.updateDrink(drinkObjectID, tastiness: tastiness)
//        }
//        
//        // Delete all measured ingredients and directions and append new ones
//        try await DrinkCDClient.deleteAllMeasuredIngredients(in: drinkObjectID)
//        try await DrinkCDClient.deleteAllDirections(in: drinkObjectID)
//        
//        for ingredientAndMeasurement in fcResponse.body.ingredientsAndMeasurements {
//            try await DrinkCDClient.appendMeasuredIngredient(to: drinkObjectID, ingredient: ingredientAndMeasurement.ingredient, measurement: ingredientAndMeasurement.measurement)
//        }
//        
//        for direction in fcResponse.body.directions {
//            if let index = Int16(exactly: direction.key) {
//                try await DrinkCDClient.appendDirection(to: drinkObjectID, index: index, text: direction.value)
//            } else {
//                // TODO: Handle error here
//                print("Could not convert direction index to Int16 in finalizeSaveDrink in BarbackNetworkPersistenceManager!")
//            }
//        }
//    }
//    
//    public static func getSaveCreatePanels() async throws {
//        let gcpResponse = try await BarbackNetworkService.getCreatePanels()
//        
//        CreatePanelsJSONPersistenceManager.set(gcpResponse.body.createPanels)
//    }
//    
//    public static func getSaveDrinkIngredientsPreview(authToken: String, drinkID: Int, to drinkObjectID: NSManagedObjectID) async throws {
//        // Ensure there are no ingredients stored already, otherwise return
//        guard try await DrinkCDClient.countBy(drinkObjectID: drinkObjectID) == 0 else {
//            // TODO: Handle errors
//            return
//        }
//        
//        // Build dRequest and get gdipResponse from BarbackNetworkService
//        let dRequest = DrinkIDRequest(
//            authToken: authToken,
//            drinkID: drinkID)
//        
//        let gdipRequest = try await BarbackNetworkService.getDrinkIngredientsPreview(request: dRequest)
//        
//        // Add all ingredients to drink ingredients
//        for ingredient in gdipRequest.body.ingredients {
//            try await DrinkCDClient.appendMeasuredIngredient(
//                to: drinkObjectID,
//                ingredient: ingredient,
//                measurement: nil)
//        }
//        
//    }
//    
//    public static func getSaveGlassColor(authToken: String, drinkID: Int, to drinkObjectID: NSManagedObjectID) async throws {
//        // Build dRequest and get ggcResponse from BarbackNetworkSerice
//        let dRequest = DrinkIDRequest(
//            authToken: authToken,
//            drinkID: drinkID)
//        
//        let ggcResponse = try await BarbackNetworkService.getGlassColor(request: dRequest)
//        
//        // Delete all glass gradient colors for drinkObjectID
//        try await DrinkCDClient.deleteAllGlassGradientColors(in: drinkObjectID)
//        
//        // Append each glass gradient color to drink with drinkObjectID
//        for i in 0..<ggcResponse.body.gradient.count {
//            if let iInt16 = Int16(exactly: i) {
//                try await DrinkCDClient.appendGlassGradientColor(to: drinkObjectID, index: iInt16, hexadecimal: ggcResponse.body.gradient[i])
//            } else {
//                // TODO: Handle errors
//                print("Could not cast index to Int16.. this should never happen!")
//            }
//        }
//    }
//    
//    public static func getSaveGlass(authToken: String, drinkID: Int, to drinkObjectID: NSManagedObjectID) async throws {
//        // Build ggRequest and get ggResponse from BarbackNetworkSerice
//        let dRequest = DrinkIDRequest(
//            authToken: authToken,
//            drinkID: drinkID)
//        
//        let ggResponse = try await BarbackNetworkService.getGlass(request: dRequest)
//        
//        // Save glass to drink with drinkObjectID
//        try await DrinkCDClient.updateDrink(drinkObjectID, glassImageData: ggResponse.body.imageData)
//    }
//    
//    public static func parseSaveBarItems(authToken: String, input: String) async throws {
//        // Build pbiRequest and get pbiResponse from BarbackNetworkService
//        let pbiRequest = ParsePantryItemsRequest(
//            authToken: authToken,
//            input: input)
//        
//        let pbiResponse = try await BarbackNetworkService.parseBarItems(request: pbiRequest)
//        
//        // Create duplicate bar item names array which will throw a duplicateBarItemNames BarItemPersistenceError with any duplicates so the user can be notified.. TODO: Is this a good implementation?
//        var duplicateBarItemNames: [String] = []
//        
//        // Save all bar items, capitalized, if item can be unwrapped, setting isAlcohol to false if nil
//        for barItem in pbiResponse.body.barItems {
//            if let item = barItem.item {
//                do {
//                    try await BarItemCDClient.appendBarItem(
//                        item: item.capitalized,
//                        brandName: barItem.brandName?.capitalized,
//                        alcoholType: barItem.alcoholType?.capitalized,
//                        isAlcohol: barItem.isAlcohol ?? false)
//                } catch PersistenceError.duplicateObject {
//                    // TODO: Handle errors if necessary, but this is so that the function doesn't fall through
//                    print("Removed duplicate object when parsing saving bar items in BarbackNetworkPersistenceManager!")
//                    duplicateBarItemNames.append(item)
//                }
//            }
//        }
//        
//        // Throw duplicate error if will throw dupilcate error is true
//        if !duplicateBarItemNames.isEmpty {
//            throw BarItemPersistenceError.duplicateBarItemNames(duplicateBarItemNames)
//        }
//    }
//    
//    public static func regenerateSaveDrinkDirections(authToken: String, drinkID: Int64, newInput: String? = nil, newName: String? = nil, newSummary: String? = nil, newIngredientsAndMeasurements: [(measurement: String?, ingredient: String)]? = nil) async throws {
//        // Build rddRequest and get rddResponse from BarbackNetworkService
//        let rddRequest = RegenerateDrinkDirectionsRequest(
//            authToken: authToken,
//            drinkID: drinkID,
//            newInput: newInput,
//            newName: newName,
//            newSummary: newSummary,
//            newIngredientsAndMeasurements: newIngredientsAndMeasurements?.map({RegenerateDrinkDirectionsRequest.IngredientAndMeasurement(ingredient: $0.ingredient, measurement: $0.measurement)}))
//        
//        let rddResponse = try await BarbackNetworkService.regenerateDrinkDirections(request: rddRequest)
//        
//        // Get permanent drinkObjectID for drink with drinkID
//        let drinkObjectID = try await DrinkCDClient.getDrinkPermanentID(drinkID: drinkID)
//        
//        // Delete all directions and append new ones
//        try await DrinkCDClient.deleteAllDirections(in: drinkObjectID)
//        
//        for direction in rddResponse.body.directions {
//            if let index = Int16(exactly: direction.key) {
//                try await DrinkCDClient.appendDirection(to: drinkObjectID, index: index, text: direction.value)
//            } else {
//                // TODO: Handle error here
//                print("Could not convert direction index to Int16 in regenerateSaveDrinkDirections in BarbackNetworkPersistenceManager!")
//            }
//        }
//    }
//    
//}
