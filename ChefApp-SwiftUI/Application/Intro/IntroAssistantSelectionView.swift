////
////  IntroAssistantSelectionView.swift
////  WriteSmith-SwiftUI
////
////  Created by Alex Coundouriotis on 3/30/24.
////
//
//import CoreData
//import Foundation
//import SwiftUI
//
//struct IntroAssistantSelectionView<Content: View>: View {
//    
////    @Binding var isPresented: Bool
//    @ViewBuilder var destination: ()->Content
//    
//    
//    @Environment(\.managedObjectContext) private var viewContext
//    
//    @FetchRequest(
//        sortDescriptors: [NSSortDescriptor(key: #keyPath(Assistant.usageMessages), ascending: false)],
//        predicate: NSPredicate(format: "%K = %d and %K = %d", #keyPath(Assistant.featured), true, #keyPath(Assistant.premium), false),
//        animation: .default)
//    private var assistants: FetchedResults<Assistant>
//    
//    @State private var faceDiameter: CGFloat = 106.0
//    @State private var faceFrame: CGRect = CGRect(x: 0, y: 0, width: 106.0, height: 106.0) // Width and height should be the same as faceDiameter
//    @State private var facialFeaturesScaleFactor: CGFloat = 0.76
//    @State private var faceColor: UIColor = UIColor(Colors.elementBackgroundColor)
//    @State private var faceStartAnimation: FaceAnimation = SmileCenterFaceAnimation(duration: 0.0)
//    @State private var circleInnerPadding: CGFloat = 0.0
//    
//    @State private var isShowingDestination: Bool = false
//    
//    @State private var isPulsatingNextButton: Bool = false
//    
//    @State private var selectedAssistant: Assistant?
//    
//    
//    var body: some View {
//        ZStack {
//            VStack {
//                Spacer()
//                
//                // Title
//                VStack(spacing: -12.0) {
//                    HStack {
//                        Text("Select Your")
//                        
//                        Spacer()
//                    }
//                    
//                    HStack {
//                        Text("Assistant...")
//                        
//                        Spacer()
//                    }
//                }
//                .font(.custom(Constants.FontName.heavy, size: 58.0))
//                .foregroundStyle(Colors.elementTextColor)
//                .lineLimit(2)
//                .minimumScaleFactor(0.5)
//                .padding([.leading, .trailing], 28)
//                
//                // Subtitle
//                HStack {
//                    VStack {
//                        Text("Choose your favorite **AI Assistant** to begin chatting. You can easily try other Assistants.")
//                            .font(.custom(Constants.FontName.bodyOblique, size: 14.0))
//                            .foregroundStyle(Colors.elementTextColor)
//                            .opacity(0.6)
//                    }
//                    
//                    Spacer()
//                }
//                .padding([.leading, .trailing], 28)
//                
//                faceAssistants
//                    .padding(28)
//                
//                Spacer()
//                
//                // Next Button
//                Button(action: {
//                    // Unwrap selectedAssistant, otherwise return
//                    guard let selectedAssistant = selectedAssistant else {
//                        // TODO: Handle errors if necessary
//                        print("Error unwrapping selectedAssistant in IntroAssistantSelectionView!")
//                        return
//                    }
//                    
//                    // Set as current Assistant
//                    do {
//                        try CurrentAssistantPersistence.setAssistant(selectedAssistant, in: viewContext)
//                    } catch {
//                        // TODO: Handle Errors
//                        print("Error setting Assistant to CurrentAssistantPersistence in IntroAssistantSelectionView... \(error)")
//                    }
//                    
//                    // Create Conversation with selectedAssistant and set in ConversationResumingManager
//                    do {
//                        let conversation = try ConversationCDHelper.appendConversation(
//                            modelName: GPTModels.gpt3turbo.rawValue,
//                            assistant: selectedAssistant,
//                            in: viewContext)
//                        
//                        do {
//                            try ConversationResumingManager.setConversation(conversation, in: viewContext)
//                        } catch {
//                            // TODO: Handle Errors
//                            print("Error setting Conversation to ConversationResumingManager in IntroAssistantSelectionView... \(error)")
//                        }
//                    } catch {
//                        // TODO: Handle Errors
//                        print("Error appending Conversation in IntroAssistantSelectionView... \(error)")
//                    }
//                    
//                    // Show destination
//                    DispatchQueue.main.async {
////                        self.isPresented = false
//                        self.isShowingDestination = true
//                    }
//                }) {
//                    ZStack {
//                        Text("Next...")
//                            .font(.custom(Constants.FontName.heavy, size: 24.0))
//                        
//                        HStack {
//                            Spacer()
//                            Text(Image(systemName: "chevron.right"))
//                        }
//                    }
//                }
//                .disabled(self.selectedAssistant == nil)
//                .padding()
//                .foregroundStyle(Colors.elementTextColor)
////                .foregroundStyle(Colors.elementBackgroundColor)
//                .background(Colors.buttonBackground)
////                .background(Colors.foreground)
//                .clipShape(RoundedRectangle(cornerRadius: UIConstants.cornerRadius))
//                .opacity(self.selectedAssistant == nil ? 0.4 : 1.0)
//                .padding()
//                .animatesPulsate(
//                    isPulsating: $isPulsatingNextButton,
//                    minScale: CGSize(width: 0.96, height: 0.96),
//                    maxScale: CGSize(width: 1.00, height: 1.00),
//                    speed: 0.5)
//                .animatesShake(
//                    isMoving: $isPulsatingNextButton,
//                    maxAngle: .degrees(0.5),
//                    speed: 0.25)
//            }
//        }
//        .background(Colors.elementBackgroundColor)
//        .navigationBarBackButtonHidden(true)
//        .onAppear {
//            // Set first assistant to random Assistant TODO: Commented out for now
//            DispatchQueue.main.async {
//                withAnimation {
//                    self.selectedAssistant = assistants.randomElement()
//                }
//            }
//        }
//        .onChange(of: selectedAssistant) { newValue in
//            if newValue == nil {
//                // Set isPulsatingNextButton to false if newValue is nil
//                isPulsatingNextButton = false
//            } else {
//                // Set isPulsatingNextButton to true otherwise, checking if selectedAssistant is still not nil before setting to true
//                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
//                    if self.selectedAssistant != nil {
//                        self.isPulsatingNextButton = true
//                    }
//                }
//            }
//        }
//        .navigationDestination(isPresented: $isShowingDestination, destination: destination)
//    }
//    
//    var faceAssistants: some View {
//        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())]) {
//            ForEach(assistants) { assistant in
//                if let faceStyle = assistant.faceStyle,
//                   let name = assistant.name,
//                   let shortDescription = assistant.assistantShortDescription {
//                    Button(action: {
//                        DispatchQueue.main.async {
//                            withAnimation(.spring(duration: 0.2)) {
//                                self.selectedAssistant = assistant
//                            }
//                        }
//                    }) {
//                        FaceAssistantView(
//                            faceAnimationViewRepresentable: FaceAnimationViewRepresentable(
//                                frame: faceFrame,
//                                eyesImageName: faceStyle.eyesImageName,
//                                mouthImageName: faceStyle.mouthImageName,
//                                noseImageName: faceStyle.noseImageName,
//                                faceImageName: faceStyle.backgroundImageName,
//                                facialFeaturesScaleFactor: facialFeaturesScaleFactor,
//                                eyesPositionFactor: faceStyle.eyesPositionFactor,
//                                faceRenderingMode: faceStyle.faceRenderingMode,
//                                color: UIColor(Colors.elementBackgroundColor),
//                                startAnimation: SmileCenterFaceAnimation(duration: 0.0),
////                                queuedAnimations: self.selectedAssistant == assistant ? State(initialValue: [SmileLookUpFaceAnimation(), SmileLookUpFaceAnimation()]) : State(initialValue: []),
//                                idleAnimations: RandomFaceIdleAnimationSequence.smile.animationSequence.animations),
//                            circleInnerPadding: circleInnerPadding - 8.0,
//                            title: name,
//                            subtitle: shortDescription,
//                            premiumModel: false)
//                    }
//                    .foregroundStyle(assistant == selectedAssistant ? Colors.elementTextColor : .black)
//                    .frame(maxWidth: .infinity, maxHeight: .infinity)
//                    .padding(8)
//                    .background(assistant == selectedAssistant ? Colors.elementTextColor.opacity(0.2) : Colors.elementTextColor)
//                    .clipShape(RoundedRectangle(cornerRadius: 14.0))
//                }
//            }
//        }
//    }
//    
//}
//
//
//#Preview {
//    
//    IntroAssistantSelectionView(destination: {})
//        .environment(\.managedObjectContext, CDClient.mainManagedObjectContext)
//        .onAppear {
//            Task(priority: .high) {
////                do {
//////                    try await DefaultAssistantsCoreDataLoader.deleteDeviceCreatedAssistantsInCoreData(in: CDClient.mainManagedObjectContext)
////                    
////                    // TODO: Version handling
////                    if try await !DefaultAssistantsCoreDataLoader.deviceCreatedAssistantExists(in: CDClient.mainManagedObjectContext) {
////                        try await DefaultAssistantsCoreDataLoader.loadDefaultAssistantsInCoreData(in: CDClient.mainManagedObjectContext)
////                    }
////                } catch {
////                    // TODO: Handle Errors
////                    print("Error loading or checking default assistants in CoreData... \(error)")
////                }
//            }
//        }
////    IntroAssistantSelectionView(destination: {
////        
////    })
////    .environment(\.managedObjectContext, CDClient.mainManagedObjectContext)
//    
//}
