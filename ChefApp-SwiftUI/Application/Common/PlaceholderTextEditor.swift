////
////  PlaceholderTextEditor.swift
////  Barback
////
////  Created by Alex Coundouriotis on 9/19/23.
////
//
//import Foundation
//import SwiftUI
//
//struct PlaceholderTextEditor: View {
//
//    let placeholder: String
//
//    let standardTextColor: Color = .accentColor
//    let placeholderTextColor: Color
//
//    @State public var text: String
//    @FocusState private var isEditing: Bool
//
//    init(placeholder: String, placeholderTextColor: Color) {
//        self.placeholder = placeholder
//        self.placeholderTextColor = placeholderTextColor
//
//        text = self.placeholder
//    }
//
//    var body: some View {
//        HStack {
//            TextField("Tap", text: $text, axis: .vertical)
//                .foregroundColor((text == placeholder && !isEditing) ? placeholderTextColor : standardTextColor)
//                .onTapGesture {
//                    if text == placeholder {
//                        text = ""
//                    }
//                }
//                .textFieldStyle(.roundedBorder)
//
//            TextField("", text: $text) {
//
//            }
//        }
//    }
//
//}
//
//
//struct PlaceholderTextEditor_PreviewProvider: PreviewProvider {
//    static var previews: some View {
//        PlaceholderTextEditor(placeholder: "asdf", placeholderTextColor: .gray)
//    }
//}
