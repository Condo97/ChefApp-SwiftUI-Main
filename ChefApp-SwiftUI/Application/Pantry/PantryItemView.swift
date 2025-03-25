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
    
    var customDateFormatter: DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d, h:mm a"
        return dateFormatter
    }
    
    var body: some View {
        VStack {
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
