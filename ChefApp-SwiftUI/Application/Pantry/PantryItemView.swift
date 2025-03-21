//
//  PantryItemView.swift
//  Barback
//
//  Created by Alex Coundouriotis on 9/18/23.
//

import Foundation
import SwiftUI

struct PantryItemView: View {
    
    @State var pantryItem: PantryItem
    var titleNoSubtitleFont: Font = .custom(Constants.FontName.body, size: 17.0)
//    var titleFont: Font = .custom(Constants.FontName.heavy, size: 17.0) TODO: This is not implemented anymore due to subtitle not being implemented
//    var subtitleFont: Font = .custom(Constants.FontName.light, size: 12.0) TODO: This is not implemented anymore check if this should be or improves functionality
    
//    var image: UIImage
    
//    static func from(pantryItem: PantryItem, titleFont: Font = .custom(Constants.FontName.heavy, size: 17.0), subtitleFont: Font = .custom(Constants.FontName.light, size: 12.0)) -> PantryItemView? {
//        guard let title = pantryItem.name else {
//            // TODO: Handle errors
//            return nil
//        }
//        let subtitle: String? = {
//            if pantryItem.amount >
//            
//            return nil
//        }()
//        
//        return PantryItemView(title: LocalizedStringKey(title), subtitle: subtitle, titleFont: titleFont, subtitleFont: subtitleFont)
//    }
    
    var customDateFormatter: DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d, h:mm a"
        return dateFormatter
    }
    
    var body: some View {
        VStack {
//            Image(uiImage: data.image)
//                .resizable()
//                .aspectRatio(contentMode: .fit)
            if let name = pantryItem.name {
                Text(name)
                    .font(titleNoSubtitleFont)
                    .foregroundStyle(Colors.foregroundText)
            }
        }
    }
    
}

#Preview {
    
    let pantryItem = try! CDClient.mainManagedObjectContext.performAndWait {
        let fetchRequest = PantryItem.fetchRequest()
        
        fetchRequest.fetchLimit = 1
        
        return try CDClient.mainManagedObjectContext.fetch(fetchRequest)[0]
    }
    
    return PantryItemView(
        pantryItem: pantryItem
    )
}
