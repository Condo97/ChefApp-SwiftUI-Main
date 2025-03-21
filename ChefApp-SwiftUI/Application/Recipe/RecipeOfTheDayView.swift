//
//  RecipeOfTheDayView.swift
//  ChefApp-SwiftUI
//
//  Created by Alex Coundouriotis on 11/29/24.
//

import SwiftUI

struct RecipeOfTheDayView: View {
    
    @ObservedObject var recipe: Recipe
    let timeFrame: TimeFrames
    let onReload: () -> Void
    
    enum TimeFrames: String, CaseIterable {
        case breakfast  =   "breakfast"
        case lunch      =   "lunch"
        case dinner     =   "dinner"
        
        // Used for display
        var displayString: String {
            switch self {
            case .breakfast: "Breakfast"
            case .lunch: "Lunch"
            case .dinner: "Dinner"
            }
        }
        
        // Used for sorting
        var sortOrder: Int {
            switch self {
            case .breakfast: 0
            case .lunch: 1
            case .dinner: 2
            }
        }
        
        private var hourRange: (start: Int, end: Int) {
            switch self {
            case .breakfast:
                return (start: 0, end: 10)     // 6:00 AM to 10:00 AM
            case .lunch:
                return (start: 10, end: 14)    // 11:00 AM to 2:00 PM
            case .dinner:
                return (start: 18, end: 24)    // 6:00 PM to 9:00 PM
            }
        }
        
        /// Checks if the current time is within the time range of the enum case
        func isTimeWithin(date: Date) -> Bool {
            let calendar = Calendar.current
            
            // Extract the current hour and minute
            let components = calendar.dateComponents([.hour], from: date)
            guard let hour = components.hour else {
                return false
            }
            
            // Convert current time to minutes since midnight
            let currentHours = hour
            
            // Get the start and end minutes for the time frame
            let range = self.hourRange
            
            return currentHours >= range.start && currentHours <= range.end
        }
        
        /// Returns the current time frame based on the current time
        static func timeFrame(for date: Date) -> TimeFrames? {
            let frames: [TimeFrames] = TimeFrames.allCases
            for frame in frames {
                if frame.isTimeWithin(date: date) {
                    return frame
                }
            }
            return nil
        }
    }
    
    @Environment(\.managedObjectContext) private var viewContext
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0.0) {
            HStack {
                // Timeframe
                Text(timeFrame.displayString)
                    .font(.custom(Constants.FontName.heavy, size: 24.0))
                
                Spacer()
            }
            .padding(.bottom, 12)
            
            Group {
                if let image = recipe.imageFromAppData {
                    Image(uiImage: image) // TODO: Fix image size and modifiers
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                } else {
                    ZStack {
                        Colors.background
                        ProgressView()
                            .tint(Colors.foregroundText)
                    }
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 14.0))
            .frame(height: 100.0)
            .padding(.bottom, 12)
            
            HStack(alignment: .top) {
                Text(recipe.name ?? "*No Title*")
                    .font(.custom(Constants.FontName.black, size: 17.0))
                    .multilineTextAlignment(.leading)
                Spacer()
//                    if let date = recipe.creationDate {
//                        Text(NiceDateFormatter.dateFormatter.string(from: date))
//                            .font(.custom(Constants.FontName.body, size: 12.0))
//                    }
            }
            
            if let summary = recipe.summary {
                HStack {
                    Text(summary)
                        .lineLimit(nil)
                        .fixedSize(horizontal: false, vertical: true)
                        .font(.custom(Constants.FontName.body, size: 14.0))
                        .multilineTextAlignment(.leading)
                    Spacer()
                }
            }
            
            Spacer()
            
            Text("View Recipe")
                .font(.custom(Constants.FontName.heavy, size: 17.0))
                .foregroundStyle(Colors.elementBackground)
                .frame(maxWidth: .infinity)
        }
        .overlay(alignment: .topTrailing) {
            VStack(spacing: 16.0) {
                // Add recipe button
                Button(action: {
                    Task {
                        do {
                            try await RecipeCDClient.updateRecipe(recipe, saved: !recipe.saved, in: viewContext)
                        } catch {
                            // TODO: Handle Errors
                            print("Error updating recipe dailyRecipe_isSavedToRecipes in RecipeOfTheDayView... \(error)")
                        }
                    }
                }) {
                    VStack {
                        Text(Image(systemName: recipe.saved ? "star.fill" : "star"))
                            .font(.body, 17.0)
                        Text(recipe.saved ? "Saved" : "Save")
                            .font(.heavy, 12.0)
                    }
//                    .padding(.vertical, 8)
//                    .padding(.horizontal)
                }
                .foregroundStyle(recipe.saved ? Colors.elementBackground : Colors.elementBackground)
                
                // Reload recipe button
                Button(action: onReload) {
                    VStack {
                        Text(Image(systemName: "square.stack"))
                            .font(.body, 17.0)
                        Text("Browse")
                            .font(.heavy, 12.0)
                    }
//                    .padding(.vertical, 8)
//                    .padding(.horizontal)
                }
                .foregroundStyle(Colors.elementBackground)
                
                // Share recipe button
                if let url = RecipeShareURLMaker.getShareURL(recipeID: Int(recipe.recipeID)) {
                    ShareLink(item: url) {
                        HStack {
                            VStack {
                                Text(Image(systemName: "square.and.arrow.up"))
                                    .font(.body, 17.0)
                                Text("Share")
                                    .font(.heavy, 12.0)
                            }
                        }
//                        .padding(.vertical, 8)
//                        .padding(.horizontal)
                    }
                    .foregroundStyle(Colors.elementBackground)
                }
            }
        }
    }
    
}

#Preview {
    
    RecipeOfTheDayView(
        recipe: try! CDClient.mainManagedObjectContext.fetch(Recipe.fetchRequest()).first!,
        timeFrame: .breakfast,
        onReload: {
            
        })
    .frame(height: 450.0)
    .environment(\.managedObjectContext, CDClient.mainManagedObjectContext)
    
}
