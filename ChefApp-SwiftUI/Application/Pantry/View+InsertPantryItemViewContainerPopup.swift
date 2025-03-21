////
////  addToPantryPopup.swift
////  ChefApp-SwiftUI
////
////  Created by Alex Coundouriotis on 6/22/24.
////
//
//import Foundation
//import SwiftUI
//
//extension View {
//    
//    func addToPantryPopup(isPresented: Binding<Bool>, showCameraOnAppear: Bool) -> some View {
//        self
//            .clearFullScreenCover(isPresented: isPresented) {
//                ScrollView {
//                    InsertPantryItemViewContainer(
//                        isActive: isPresented,
//                        showCameraOnAppear: showCameraOnAppear)
//                        .padding(24.0)
//                        .background(Colors.background)
//                        .cornerRadius(28.0)
//                        .padding()
//                }
////                VStack {
////                    Spacer()
////                    HStack {
////                        Spacer()
////                        ScrollView {
////                            InsertPantryItemView(isShowing: isPresented)
////                                .padding(24.0)
////                                .background(Colors.background)
////                                .cornerRadius(28.0)
////                        }
////                        Spacer()
////                    }
////                    Spacer()
////                }
//            }
//    }
//    
//}
