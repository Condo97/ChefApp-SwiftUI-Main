//
//  RecipeMiniView.swift
//  Barback
//
//  Created by Alex Coundouriotis on 9/18/23.
//

import Foundation
import SwiftUI

class RecipeMiniViewModel: ObservableObject {
    
    /// The recipe's display title
    var title: String
    
    /// Optional short description or summary of the recipe
    var summary: String?
    
    /// Optional thumbnail image for the recipe
    var image: UIImage?
    
    /// Last updated date used for display freshness
    var date: Date?
    
    /// Flag indicating if the recipe originated from TikTok
    let isFromTikTok: Bool
    
    init(title: String, summary: String?, image: UIImage?, date: Date, isFromTikTok: Bool) {
        self.title = title
        self.summary = summary
        self.image = image
        self.date = date
        self.isFromTikTok = isFromTikTok
    }
    
    // MARK: - Factory
    
//    /// Creates a RecipeMiniViewModel from a Core Data Recipe entity
//    static func from(recipe: Recipe) -> RecipeMiniViewModel? {
//        guard let title = recipe.name else {
//            // TODO: [Error Handling] Handle Errors
//            return nil
//        }
//        
//        let summary = recipe.summary
//        let date = recipe.updateDate ?? Date.distantPast
//        let image = recipe.imageFromAppData
//        let isFromTikTok = recipe.sourceTikTokVideoID != nil
//        
//        return RecipeMiniViewModel(
//            title: title,
//            summary: summary,
//            image: image,
//            date: date,
//            isFromTikTok: isFromTikTok)
//    }
    
    
}

/**
 Card-style view displaying key recipe information in lists and grids.
 */
struct RecipeMiniView: View {
    
    @StateObject var viewModel: RecipeMiniViewModel
    
    var body: some View {
        HStack(alignment: .top) {
            // Left-side image column
            VStack {
                ZStack {
                    Group {
                        if let image = viewModel.image {
                            Image(uiImage: image) // TODO: [Layout] Fix image size and modifiers
                                .resizable()
                                .aspectRatio(1, contentMode: .fill)
                        } else {
                            // Fallback loading indicator
                            ZStack {
                                Colors.background
                                ProgressView()
                                    .tint(Colors.foregroundText)
                            }
                        }
                    }
                    .clipShape(RoundedRectangle(cornerRadius: 14.0))
                    .frame(width: 48.0, height: 48.0)
                }
                
                // Vertical separator line
                HStack {
                    RoundedRectangle(cornerRadius: 14.0)
                        .frame(width: 2)
                        .foregroundStyle(Colors.background)
                        .padding(.leading)
                        .padding(.top, 8)
                }
            }
            
            Spacer(minLength: 15)
            
            // Right-side content column
            VStack {
                VStack {
                    // Title and date row
                    HStack(alignment: .top) {
                        Text(viewModel.title)
                            .font(.custom(Constants.FontName.black, size: 17.0))
                            .multilineTextAlignment(.leading)
                        Spacer()
                        if let date = viewModel.date {
                            Text(NiceDateFormatter.dateFormatter.string(from: date))
                                .font(.custom(Constants.FontName.body, size: 12.0))
                        }
                    }
                    
                    // Summary section
                    if let description = viewModel.summary {
                        Spacer()
                        HStack {
                            Text(description)
                                .lineLimit(nil)
                                .fixedSize(horizontal: false, vertical: true)
                                .font(.custom(Constants.FontName.body, size: 14.0))
                                .multilineTextAlignment(.leading)
                            Spacer()
                        }
                        Spacer()
                    }
                    
                    // TikTok branding
                    if viewModel.isFromTikTok {
                        HStack {
                            Image(Constants.Images.tikTokLogo)
                                .resizable()
                                .frame(width: 16, height: 16)
                            Text("From TikTok")
                                .font(.heavy, 12)
                                .italic()
                                .opacity(0.6)
                            Spacer()
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Preview Provider

struct RecipeMiniView_PreviewProvider: PreviewProvider {
    
    static var previews: some View {
        ZStack {
            RecipeMiniView(
                viewModel: RecipeMiniViewModel(
                    title: "Title",
                    summary: "Description",
                    image: UIImage(named: "HighballTest")!,
                    date: Date(),
                    isFromTikTok: true))
        }
        .environmentObject(PremiumUpdater())
        .environmentObject(ProductUpdater())
        .environmentObject(RemainingUpdater())
    }
}
