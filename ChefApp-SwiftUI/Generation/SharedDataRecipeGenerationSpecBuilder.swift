//
//  ImportedRecipeGenerator.swift
//  ChefApp-SwiftUI
//
//  Created by Alex Coundouriotis on 12/20/24.
//

import Foundation
import PDFKit

class SharedDataRecipeGenerationSpecBuilder {
    
    enum Errors: Error {
        case missingText    // Could not unwrap text from sharedData
    }
    
    static func buildRecipeGenerationSpec(from sharedData: SharedData) async throws -> RecipeGenerationViewModel {
        // Get text from attachment
        guard let text = await getText(from: sharedData) else {
            throw Errors.missingText
        }
        
        // Process Recipe with this as the input and return
        return RecipeGenerationViewModel(
            pantryItems: [],
            suggestions: [],
            input: text,
            generationAdditionalOptions: .normal)
    }
    
    static func getText(from sharedData: SharedData) async -> String? {
        if let urlString = sharedData.url, // TODO: Bruth does this even work
           let url = URL(string: urlString) {
            do {
                if let receivedText = try await WebpageTextReader.getWebpageText(externalURL: url) {
                    return receivedText
                }
                
                // TODO: Prompt GPT with text
            } catch {
                // TODO: Handle Errors
                print("Error reading webpage text in WriteSmith_SwiftUIApp... \(error)")
            }
        }
        
        if let text = sharedData.text {
            return text
        }
        
        if let pdfAppGroupFilepath = sharedData.pdfAppGroupFilepath {
            if let pdfData = AppGroupLoader(appGroupIdentifier: Constants.Additional.appGroupID)
                .loadData(from: pdfAppGroupFilepath),
               let pdfDocument = PDFDocument(data: pdfData) {
                if let pdf = PDFReader.readPDF(from: pdfDocument) {
                    return pdf
                }
            }
        }
        
        return nil
    }
    
    
}
