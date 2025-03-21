//
//  BingSearchClient.swift
//  BingSearchPopup
//
//  Created by Alex Coundouriotis on 6/30/23.
//

import Foundation
import UIKit

class BingSearchClient {
    
    static let BASE_URL = "https://api.bing.microsoft.com/v7.0/images/search"
    
    static let COMPONENT_QUERY = "q"
    static let COMPONENT_COUNT = "count"
    static let COMPONENT_OFFSET = "offset"
    static let COMPONENT_SAFE_SEARCH = "safeSearch"
    static let COMPONENT_MIN_HEIGHT = "minHeight"
    static let COMPONENT_MIN_WIDTH = "minWidth"
    
    static let DEFAULT_SAFE_SEARCH: String = "Strict"
    static let DEFAULT_MIN_HEIGHT: String = "32"
    static let DEFAULT_MIN_WIDTH: String = "32"
    
    static let HEADER_API_KEY: String = "Ocp-Apim-Subscription-Key"
    
    static var HEADER_API_VALUE: String {
        Keys.BING_API_KEY ?? ""
    }
    
    static func getImages(query: String, count: Int, offset: Int) async throws -> (imageURLs: [URL], totalEstimatedMatches: Int?) {
        // Build URL
        var urlComponents = URLComponents(string: "\(BASE_URL)")!
        urlComponents.queryItems = [
            URLQueryItem(name: COMPONENT_QUERY, value: query),
            URLQueryItem(name: COMPONENT_COUNT, value: String(count)),
            URLQueryItem(name: COMPONENT_OFFSET, value: String(offset)),
            URLQueryItem(name: COMPONENT_SAFE_SEARCH, value: DEFAULT_SAFE_SEARCH),
            URLQueryItem(name: COMPONENT_MIN_HEIGHT, value: DEFAULT_MIN_HEIGHT),
            URLQueryItem(name: COMPONENT_MIN_WIDTH, value: DEFAULT_MIN_WIDTH)
        ]
        
        // Build request with API key
        var request = URLRequest(url: urlComponents.url!)
        request.addValue(HEADER_API_VALUE, forHTTPHeaderField: HEADER_API_KEY)
        
        // Do request
        let (data, response) = try await URLSession.shared.data(for: request)
        
        // Parse JSON
        let bingSearchReponse = try JSONDecoder().decode(BingSearchResponse.self, from: data)
        
        // Return UIImage array from getImagesFromBingSearchResponse
        return (imageURLs: try await getImagesFromBingSearchResponse(bingSearchReponse), totalEstimatedMatches: bingSearchReponse.totalEstimatedMatches)
    }
    
    private static func getImagesFromBingSearchResponse(_ response: BingSearchResponse) async throws -> [URL] {
        response.value.compactMap({
            if let contentURLString = $0.contentUrl,
               let contentURL = URL(string: contentURLString) {
                return contentURL
            }
            return nil
        })
//        // Create UIImage array
//        var images: [UIImage] = []
//        
//        // Get image from contentURL in each value
//        for value in response.value {
//            if let contentUrl = value.contentUrl {
//                // Create url request with value contentUrl
//                let url = URL(string: contentUrl)
//                let urlRequest = URLRequest(url: url!)
//                
//                do {
//                    // Do request
//                    let (data, response) = try await URLSession.shared.data(for: urlRequest)
//                    
//                    // Try to parse data into image and if successful, add to image array
//                    if let image = UIImage(data: data) {
//                        images.append(image)
//                    }
//                } catch {
//                    print("Error getting response when getting images from Bing search response: \(error)")
//                }
//            }
//        }
//        
//        return images
    }
    
}
