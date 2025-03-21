//
//  Recipe+Extensions.swift
//  ChefApp-SwiftUI
//
//  Created by Alex Coundouriotis on 12/10/24.
//

import Foundation
import UIKit

extension Recipe {
    
    var imageFromAppData: UIImage? {
        guard let imageAppGroupLocation else {
            // TODO: Handle Errors
            print("Could not unwrap imageAppGroupLocation in Recipe+Extensions!")
            return nil
        }
        
        guard let imageData = AppGroupLoader(appGroupIdentifier: Constants.Additional.appGroupID).loadData(from: imageAppGroupLocation) else {
            // TODO: Handle Errors
            print("Could not unwrap imageData from AppGroupLoader in Recipe+Extensions!")
            return nil
        }
        
        return UIImage(data: imageData)
    }
    
}
