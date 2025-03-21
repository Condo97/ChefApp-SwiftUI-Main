//
//  FontWeight.swift
//  MealPlanChef
//
//  Created by Alex Coundouriotis on 12/1/24.
//

import Foundation

enum FontWeight {
    
    case light, body, medium, heavy, black, damion
    
}

extension FontWeight {
    
    var appFontName: String {
        switch self {
        case .light: Constants.FontName.light
        case .body: Constants.FontName.body
        case .medium: Constants.FontName.medium
        case .heavy: Constants.FontName.heavy
        case .black: Constants.FontName.black
        case .damion: Constants.FontName.damion
        }
    }
}
