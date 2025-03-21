//
//  ComponentView.swift
//  Barback
//
//  Created by Alex Coundouriotis on 9/24/23.
//

import SwiftUI

protocol ComponentView: View {
    
    var finalizedPrompt: String? { get set }
    
}
