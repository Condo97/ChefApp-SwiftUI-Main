//
//  PanelParser.swift
//  Barback
//
//  Created by Alex Coundouriotis on 9/17/23.
//

import Foundation
import UIKit

class PanelParser {
    
    fileprivate struct PanelArray: Codable {
        
        var panels: [Panel]
        
        enum CodingKeys: String, CodingKey {
            case panels
        }
        
    }
    
    static func parsePanelsGettingImagesFromFiles(fromJson json: String) throws -> [Panel]? {
        if let data = json.data(using: .utf8) {
            return try parsePanelsGettingImagesFromFiles(fromJson: data)
        }
        
        return nil
    }
    
    static func parsePanelsGettingImagesFromFiles(fromJson jsonData: Data) throws -> [Panel]? {
        // Get panels from jsonDecoder
        let panels = try JSONDecoder().decode(PanelArray.self, from: jsonData).panels
        
        // Return panels
        return panels
    }
    
    static func parsePanelsUpdatingSavedImagesFromNetwork(fromJson json: String) async throws -> [Panel]? {
        if let data = json.data(using: .utf8) {
            return try await parsePanelsUpdatingSavedImagesFromNetwork(fromJson: data)
        }
        
        return nil
    }
    
    static func parsePanelsUpdatingSavedImagesFromNetwork(fromJson jsonData: Data) async throws -> [Panel] {
        // Get panels from jsonDecoder
        let panels = try JSONDecoder().decode(PanelArray.self, from: jsonData).panels
        
        return panels
    }
    
}
