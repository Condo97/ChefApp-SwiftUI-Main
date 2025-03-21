//
//  PantryItem+Extensions.swift
//  ChefApp-SwiftUI
//
//  Created by Alex Coundouriotis on 11/29/24.
//

import Foundation

extension PantryItem {
    
    @objc
    var daysAgoString: String? {
        if let updateDate {
            // Calculate the number of full days between the dates
            guard let days = daysAgoInt else {
                return nil
            }
            
            switch days {
            case 0:
                return "Today"
            case 1:
                return "Yesterday"
            default:
                return "\(days) Days Ago"
            }
        }
        
        return nil
    }
    
    var daysAgoInt: Int? {
        if let updateDate {
            let calendar = Calendar.current
            return calendar.dateComponents([.day], from: calendar.startOfDay(for: updateDate), to: calendar.startOfDay(for: Date())).day
        }
        
        return nil
    }
    
}
