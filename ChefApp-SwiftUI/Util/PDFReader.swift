//
//  PDFReader.swift
//  WriteSmith-SwiftUI
//
//  Created by Alex Coundouriotis on 5/4/24.
//

import Foundation
import PDFKit

class PDFReader {
    
    static func readPDF(from pdf: PDFDocument, maxChars: Int = 6500) -> String? {
        let pageCount = pdf.pageCount
        let content = NSMutableAttributedString()
        
        for i in 0..<pageCount {
            // Get page, otherwise continue
            guard let page = pdf.page(at: i) else {
                continue
            }
            
            // Get pageContent, otherwise continue
            guard let pageContent = page.attributedString else {
                continue
            }
            
            // If pageContent length plus content length is less than maxChars append to content, otherwise break
            if pageContent.length + content.length < maxChars {
                // Append pageContent to content
                content.append(pageContent)
            } else {
                // Break from for loop
                break
            }
        }
        
        return content.string
    }
    
}
