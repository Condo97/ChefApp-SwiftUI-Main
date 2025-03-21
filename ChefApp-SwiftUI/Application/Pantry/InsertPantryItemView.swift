////
////  InsertPantryItemView.swift
////  Barback
////
////  Created by Alex Coundouriotis on 9/19/23.
////
//
//import Foundation
//import SwiftUI
//
//struct InsertPantryItemView: View {
//    
//    @Binding var isShowing: Bool
////    let showCameraOnAppear: Bool
//    @State var isShowingCaptureCameraView: Bool
//    
//    let onUseManualEntry: () -> Void
//    
//    let instructionText: String = "Enter items to add to your pantry. Include produce, meats, branded items, and more."
//    let instructionExampleText: String = "ex. \"Lemon, Chicken, Pasta, Tomato Paste, etc."
//    
//    let placeholderText: String = "Tap to start typing..."
//    
//    @Environment(\.colorScheme) private var colorScheme
//    @Environment(\.managedObjectContext) private var viewContext
//    
//    @FocusState private var automaticEntryTextFieldFocusState
//    
//    @StateObject private var pantryItemsParser: PantryItemsParser = PantryItemsParser()
//    
//    @State private var automaticEntryText: String = ""
//    @State private var automaticEntryItems: [String] = []
//    
////    @State private var isUsingAutomaticEntry: Bool = true
//    
//    @State private var duplicatePantryItemNames: [String] = []
//    
//    @State private var alertShowingDuplicateAutomaticEntryItem: Bool = false
//    @State private var alertShowingDuplicateObjectWhenInserting: Bool = false
//    
//    private var isAutoSubmitButtonEnabled: Bool {
//        !automaticEntryText.isEmpty || !automaticEntryItems.isEmpty
//    }
//    
//
//    var body: some View {
//        VStack {
//            HStack {
//                Text("Add to Pantry...")
//                    .font(.custom(Constants.FontName.black, size: 28.0))
//                Spacer()
//                Button(action: {
//                    HapticHelper.doLightHaptic()
//                    
//                    // Close by setting isShowing to false
//                    withAnimation {
//                        isShowing = false
//                    }
//                }) {
//                    Image(systemName: "xmark")
//                        .font(.custom(Constants.FontName.black, size: 24.0))
//                        .foregroundColor(Colors.elementBackground)
//                }
//            }
//            .padding(.bottom, 8)
//            
//            automaticEntryView
//            
//            Button(action: {
//                HapticHelper.doLightHaptic()
//                
//                onUseManualEntry()
//            }) {
//                Text("Switch to Manual Entry")
//                    .font(.custom(Constants.FontName.heavy, size: 14.0))
//                    .foregroundStyle(Colors.elementBackground)
//                    .underline()
//            }
//            .padding(.top, 8)
//            .padding(.bottom)
//            
//            submitButtonView
//        }
//        .alert("Duplicate Entry", isPresented: $alertShowingDuplicateAutomaticEntryItem, actions: {
//            Button("Done", role: .cancel, action: {
//                
//            })
//        }) {
//            Text("This item is already in your list to add to pantry.")
//        }
//        .alert("Duplicate Item", isPresented: $alertShowingDuplicateObjectWhenInserting, actions: {
//            Button("Done", role: .cancel, action: {
//                withAnimation {
//                    isShowing = false
//                }
//            })
//        }) {
//            Text("Duplicate pantry items found and won't be added:\n" + duplicatePantryItemNames.joined(separator: ", "))
//        }
//        .fullScreenCover(isPresented: $isShowingCaptureCameraView) {
//            ZStack {
//                CaptureCameraViewControllerRepresentable(
//                    reset: .constant(false),
//                    onAttach: { image, cropFrame, unmodifiedImage in
//                        Task {
//                            do {
//                                // Get pantryItemStrings from image and add them to automaticEntryItems
//                                let pantryItemStrings = try await pantryItemsParser.parseGetPantryItemsFromImage(image: image, input: nil).map({$0.name})
//                                
//                                automaticEntryItems.append(contentsOf: pantryItemStrings)
//                            } catch {
//                                // TODO: Handle Errors
//                                print("Error getting pantry item text from image in InsertPantryItemView... \(error)")
//                            }
//                        }
//                        
//                        withAnimation {
//                            isShowingCaptureCameraView = false
//                        }
//                    })
//                
//                VStack {
//                    HStack {
//                        Spacer()
//                        Button(action: {
//                            withAnimation {
//                                HapticHelper.doLightHaptic()
//                                
//                                isShowingCaptureCameraView = false
//                            }
//                        }) {
//                            ZStack {
//                                Image(systemName: "xmark")
//                                    .resizable()
//                                    .frame(width: 30.0, height: 30.0)
//                                    .foregroundStyle(Colors.elementText)
//                                
//                                Image(systemName: "xmark")
//                                    .resizable()
//                                    .frame(width: 28.0, height: 28.0)
//                                    .foregroundStyle(Colors.elementBackground)
//                            }
//                            .padding(.top)
//                            .padding()
//                            .padding()
//                        }
//                    }
//                    Spacer()
//                }
//            }
//            .ignoresSafeArea()
//        }
//    }
//    
//    var automaticEntryView: some View {
//        VStack {
//            // Automatic Entry Field and Entered Items
//            SingleAxisGeometryReader(axis: .horizontal) { geo in
//                VStack(alignment: .leading) {
//                    FlexibleView(availableWidth: geo.magnitude, data: automaticEntryItems, spacing: 8.0, alignment: .leading) { selectedItem in
//                        Button(action: {
//                            HapticHelper.doLightHaptic()
//                            
//                            withAnimation {
//                                automaticEntryItems.removeAll(where: {$0 == selectedItem})
//                            }
//                        }) {
//                            Text("\(selectedItem) \(Image(systemName: "xmark"))")
//                                .font(.custom(Constants.FontName.body, size: 14.0))
//                                .foregroundStyle(Colors.foregroundText)
//                                .padding([.top, .bottom], 8)
//                                .padding([.leading, .trailing])
//                                .background(Colors.foreground)
//                                .clipShape(RoundedRectangle(cornerRadius: 14.0))
//                        }
//                    }
//                    
//                    TextField(placeholderText, text: $automaticEntryText)
//                        .textFieldTickerTint(colorScheme == .light ? Colors.elementBackground : Colors.foregroundText)
//                        .keyboardDismissingTextFieldToolbar("Done", color: Colors.elementBackground)
//                        .focused($automaticEntryTextFieldFocusState)
//                        .font(.custom(Constants.FontName.body, size: 17.0))
//                        .foregroundColor(Colors.foregroundText)
//                        .padding()
//                        .background(Colors.foreground)
//                        .clipShape(RoundedRectangle(cornerRadius: 20.0))
//                        .onSubmit {
//                            // Set textField to focused to bring up keyboard
//                            UIView.performWithoutAnimation {
//                                automaticEntryTextFieldFocusState = true
//                            }
//                            
//                            // Loop through automaticEntryText split by comma separator
//                            for item in automaticEntryText.split(separator: ", ") {
//                                // Ensure automaticEntryText is not in automaticEntryItems, otherwise return
//                                guard !automaticEntryItems.contains(String(item)) else {
//                                    alertShowingDuplicateAutomaticEntryItem = true
//                                    return
//                                }
//                                
//                                // Take automaticEntryText and add it to automaticEnteredItems
//                                automaticEntryItems.append(String(item))
//                            }
//                            
//                            // Set automaticEntryText to blank
//                            automaticEntryText = ""
//                        }
//                }
//            }
//            
//            // Instructions
//            Text(instructionText)
//                .font(.custom(Constants.FontName.light, size: 14.0))
//                .multilineTextAlignment(.center)
//                .opacity(0.4)
//            Text(instructionExampleText)
//                .font(.custom(Constants.FontName.lightOblique, size: 14.0))
//                .multilineTextAlignment(.center)
//                .opacity(0.4)
//            
//            // Add with Camera Button
//            Button(action: {
//                HapticHelper.doLightHaptic()
//                
//                isShowingCaptureCameraView = true
//            }) {
//                ZStack {
//                    HStack {
//                        Spacer()
//                        Image(systemName: "chevron.right")
//                            .imageScale(.medium)
//                    }
//                    HStack {
//                        Spacer()
//                        Text("\(Image(systemName: "camera")) Scan to Add")
//                            .font(.custom(Constants.FontName.heavy, size: 20.0))
//                        Spacer()
//                    }
//                }
//            }
//            .padding()
//            .background(
//                ZStack {
//                    RoundedRectangle(cornerRadius: 14.0)
//                        .stroke(Colors.elementBackground)
//                    RoundedRectangle(cornerRadius: 14.0)
//                        .fill(Colors.elementText)
//                }
//            )
//            .foregroundStyle(Colors.elementBackground)
//            .clipShape(RoundedRectangle(cornerRadius: 14.0))
//            .padding(.top)
//            
//            // Add with Camera Description
//            HStack {
//                Text("Take a picture of your pantry, fridge, receipt items, and more. AI will automatically find and add items.")
//                    .font(.custom(Constants.FontName.light, size: 14.0))
//                    .multilineTextAlignment(.center)
//                    .opacity(0.4)
//                Spacer()
//            }
//        }
//    }
//    
//    var submitButtonView: some View {
//        Button(action: {
//            HapticHelper.doMediumHaptic()
//            
//            Task {
//                let authToken: String
//                do {
//                    authToken = try await AuthHelper.ensure()
//                } catch {
//                    // TODO: Handle errors
//                    print("Error ensuring authToken in InsertPantryItemView... \(error)")
//                    return
//                }
//                
//                // Parse save bar items
//                do {
//                    try await pantryItemsParser.parseSavePantryItems(
//                        input: automaticEntryItems.joined(separator: ", ") + "\n" + automaticEntryText,
//                        in: viewContext)
//                    
//                    // Do success haptic
//                    HapticHelper.doSuccessHaptic()
//                    
//                    // Close by setting isShowing to false with animation
//                    withAnimation {
//                        isShowing = false
//                    }
//                } catch PantryItemPersistenceError.duplicatePantryItemNames(let duplicatePantryItemNames) {
//                    // Do warning haptic
//                    HapticHelper.doWarningHaptic()
//                    
//                    // Set instance dupliactePantryItemsNames to dupliactePantryItemNames from error
//                    self.duplicatePantryItemNames = duplicatePantryItemNames
//                    alertShowingDuplicateObjectWhenInserting = true
//                } catch {
//                    // TODO: Handle errors
//                    print("Error parsing and saving bar items in body in InsertPantryItemView... \(error)")
//                }
//            }
//        }) {
//            ZStack {
//                if pantryItemsParser.isLoading {
//                    // Progress view
//                    HStack {
//                        Spacer()
//                        ProgressView()
//                            .tint(Colors.elementText)
//                    }
//                } else {
//                    // Chevron
//                    HStack {
//                        Spacer()
//                        Image(systemName: "chevron.right")
//                    }
//                }
//                
//                // Add to pantry text
//                HStack {
//                    Spacer()
//                    Text("Submit")
//                        .font(.custom(Constants.FontName.heavy, size: 20.0))
//                    Spacer()
//                }
//            }
//        }
//        .foregroundColor(Colors.elementText)
//        .padding()
//        .background(Colors.elementBackground)
//        .cornerRadius(20.0)
//        .opacity(isAutoSubmitButtonEnabled ? 1.0 : 0.4)
//        .disabled(!isAutoSubmitButtonEnabled)
//        .disabled(pantryItemsParser.isLoading)
//        .opacity(pantryItemsParser.isLoading ? 0.4 : 1.0)
//    }
//
//}
//
//struct InsertPantryItemView_PreviewProvider: PreviewProvider {
//    static var previews: some View {
//        InsertPantryItemView(
//            isShowing: .constant(false),
//            isShowingCaptureCameraView: false,
//            onUseManualEntry: {
//                print("Use Manual Entry Tapped")
//            })
//            .background(Color(uiColor: .secondarySystemBackground))
//            .environmentObject(PremiumUpdater())
//            .environmentObject(ProductUpdater())
//            .environmentObject(RemainingUpdater())
//    }
//}
