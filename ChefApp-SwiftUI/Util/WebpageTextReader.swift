//
//  WebpageTextReader.swift
//  WriteSmith-SwiftUI
//
//  Created by Alex Coundouriotis on 5/4/24.
//

import Foundation
import PDFKit

class WebpageTextReader {
    
    static func getWebpageText(externalURL: URL, maxChars: Int = 6500) async throws -> String? {
        var request = URLRequest(url: externalURL)
//        request.addValue("text/plain", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "GET"
        request.timeoutInterval = 60
        
//        let (data, response) = try await URLSession.shared.data(for: request)
        let (data, response) = try await URLSession.shared.data(from: externalURL)
        
        if let html = String(data: data, encoding: .utf8) {
//            // If html can be unwrapped parse with SwiftSoup to get text and return prefixed to a set amount
//            let document: Document = try SwiftSoup.parse(html)
//            return try String(document.text().prefix(3000))
            
            return await withCheckedContinuation { continuation in
                NSAttributedString.loadFromHTML(data: data, completionHandler: { string, attributes, error in
                    if let trimmedString = string?.string.prefix(maxChars) {
                        continuation.resume(returning: String(trimmedString))
                    } else {
                        continuation.resume(returning: nil)
                    }
                })
            }
        } else {
            // html could be nil because externalURL refers to a file that is not received in data with GET so try decoding it as a PDF and return
            if let pdf = PDFDocument(data: data) {
                return PDFReader.readPDF(
                    from: pdf,
                    maxChars: maxChars)
            }
        }
        
        return nil
        
        
        
//        let html: String
//        do {
//            
//        } catch let error as NSError {
//            if error.code == 264 {
//                // Error is probably because externalURL refers to a file that is not decodable with String(contextOf: ) so try decoding it as a PDF and return
//                if let pdf = PDFDocument(url: externalURL) {
//                    return PDFReader.readPDF(from: pdf)
//                }
//            }
//            
//            throw error
//        }
//        let document: Document = try SwiftSoup.parse(html)
//        return try String(document.text().prefix(3000))
        
//        if let pdf = PDFDocument(data: pdfData) {
//            let pageCount = pdf.pageCount
//            let content = NSMutableAttributedString()
//
//            for i in 0..<pageCount {
//                // Get page, otherwise continue
//                guard let page = pdf.page(at: i) else {
//                    continue
//                }
//
//                // Get pageContent, otherwise continue
//                guard let pageContent = page.attributedString else {
//                    continue
//                }
//
//                // Append pageContent to content
//                content.append(pageContent)
//            }
//
//            return content.string
//        }
//
//        return nil
    }
    
}
