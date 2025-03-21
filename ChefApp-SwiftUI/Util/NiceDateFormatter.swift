//
//  NiceDateFormatter.swift
//  Barback
//
//  Created by Alex Coundouriotis on 9/29/23.
//

import Foundation

class NiceDateFormatter {
    
    static let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d, h:mm a"
        return dateFormatter
    }()
    
}
