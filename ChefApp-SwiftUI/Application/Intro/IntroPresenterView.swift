//
//  IntroPresenterView.swift
//  WriteSmith-SwiftUI
//
//  Created by Alex Coundouriotis on 11/1/23.
//

import AVKit
//import FirebaseAnalytics
import SwiftUI

struct IntroPresenterView: View {
    
    @Binding var isShowing: Bool
    
    
    @Environment(\.colorScheme) private var colorScheme
    
    
    private let lightModeIntroNew1Name = "Intro New 1 Light"
    private let lightModeIntroNew1Extension = "mp4"
    private let darkModeIntroNew1Name = "Intro New 1 Dark"
    private let darkModeIntroNew1Extension = "mp4"
    
    private let lightModeIntroNew2Name = "Intro New 2 Light"
    private let lightModeIntroNew2Extension = "mp4"
    private let darkModeIntroNew2Name = "Intro New 2 Dark"
    private let darkModeIntroNew2Extension = "mp4"
    
    static let lightModeImage1Name = "Intro Screenshot 1 Light"
    static let darkModeImage1Name = "Intro Screenshot 1 Dark"
    static let lightModeImage2Name = "Intro Screenshot 2 Light"
    static let darkModeImage2Name = "Intro Screenshot 2 Dark"
    
    private let videoAspectRatio = 1284.0/2778.0
    
    private let showFirstButtonLoadingDelay: CGFloat = 1.0
    
    
//    @State private var video1AVPlayer: AVPlayer
//    @State private var video2AVPlayer: AVPlayer
    
    @State private var isShowingFirstButtonLoading: Bool = true
    
    
    init(isShowing: Binding<Bool>) {
        self._isShowing = isShowing
        
        let initialColorScheme: ColorScheme = UIScreen.main.traitCollection.userInterfaceStyle == .dark ? .dark : .light
//        self._video1AVPlayer = State(initialValue: IntroPresenterView.setupAVPlayer(
//            lightVideoName: lightModeIntroNew1Name,
//            lightVideoExtension: lightModeIntroNew1Extension,
//            darkVideoName: darkModeIntroNew1Name,
//            darkVideoExtension: darkModeIntroNew1Extension,
//            colorScheme: initialColorScheme))
//        self._video2AVPlayer = State(initialValue: IntroPresenterView.setupAVPlayer(
//            lightVideoName: lightModeIntroNew2Name,
//            lightVideoExtension: lightModeIntroNew2Extension,
//            darkVideoName: darkModeIntroNew2Name,
//            darkVideoExtension: darkModeIntroNew1Extension,
//            colorScheme: initialColorScheme))
    }
    
    
    var body: some View {
//        let generateImageAVPlayer = AVPlayer(url: Bundle.main.url(
//            forResource: colorScheme == .light ? lightModeIntroNew1Name : darkModeIntroNew1Name,
//            withExtension: colorScheme == .light ? lightModeIntroNew1Extension : darkModeIntroNew1Extension)!)
//        let scanImageAVPlayer = AVPlayer(url: Bundle.main.url(
//            forResource: colorScheme == .light ? lightModeIntro2Name : darkModeIntro2Name,
//            withExtension: colorScheme == .light ? lightModeIntro2Extension : darkModeIntro2Extension)!)
        
        NavigationStack {
            IntroView(
                image: Image(uiImage: UIImage(named: colorScheme == .dark ? IntroPresenterView.darkModeImage1Name : IntroPresenterView.lightModeImage1Name)!), // TODO: Fix when transition
                isShowingButtonLoading: $isShowingFirstButtonLoading,
                destination: {
                    IntroView(
                        image: Image(uiImage: UIImage(named: colorScheme == .dark ? IntroPresenterView.darkModeImage2Name : IntroPresenterView.lightModeImage2Name)!),
                        isShowingButtonLoading: $isShowingFirstButtonLoading,
                        destination: {
                            UltraView(isShowing: $isShowing)
                                .toolbar(.hidden, for: .navigationBar)
                                .onAppear {
                                    IntroManager.isIntroComplete = true
                                }
                        })
//                IntroVideoView(
//                    avPlayer: $video1AVPlayer,
//                    showReplayDelay: 3.0,
//                    videoAspectRatio: videoAspectRatio,
//                    destination: {
//                        IntroVideoView(
//                            avPlayer: $video2AVPlayer,
//                            showReplayDelay: 2.0,
//                            videoAspectRatio: videoAspectRatio,
//                            destination: {
////                                IntroAssistantSelectionView {
//                                    UltraView(isShowing: $isShowing)
//                                        .toolbar(.hidden, for: .navigationBar)
//                                        .onAppear {
////                                            // Log fifth intro view
////                                            Analytics.logEvent("intro_progression_v5.4", parameters: [
////                                                "view": 5 as NSObject
////                                            ])
////                                            
////                                            Analytics.logEvent(AnalyticsEventScreenView,
////                                                               parameters: [AnalyticsParameterScreenName: "UltraViewFromIntro",
////                                                                           AnalyticsParameterScreenClass: "UltraViewFromIntro"])
//                                            
//                                            IntroManager.isIntroComplete = true
//                                        }
//                            })
//                        .onAppear {
////                            // Log third intro view
////                            Analytics.logEvent("intro_progression_v5.4", parameters: [
////                                "view": 3 as NSObject
////                            ])
////                            
////                            Analytics.logEvent(AnalyticsEventScreenView,
////                                               parameters: [AnalyticsParameterScreenName: "IntroView3",
////                                                           AnalyticsParameterScreenClass: "IntroView3"])
//                        }
//                    })
//                .onAppear {
////                    // Log second intro view
////                    Analytics.logEvent("intro_progression_v5.4", parameters: [
////                        "view": 2 as NSObject
////                    ])
////                    
////                    Analytics.logEvent(AnalyticsEventScreenView,
////                                       parameters: [AnalyticsParameterScreenName: "IntroView2",
////                                                   AnalyticsParameterScreenClass: "IntroView2"])
//                }
            })
            .onAppear {
//                // Log first intro view
//                Analytics.logEvent("intro_progression_v5.4", parameters: [
//                    "view": 1 as NSObject
//                ])
//                
//                Analytics.logEvent(AnalyticsEventScreenView,
//                                   parameters: [AnalyticsParameterScreenName: "IntroView1",
//                                               AnalyticsParameterScreenClass: "IntroView1"])
            }
        }
        .onAppear {
            DispatchQueue.main.async {
                // Load AVPlayerViewController so that video loading is faster
                AVPlayerViewController.load()
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + showFirstButtonLoadingDelay) {
                withAnimation {
                    self.isShowingFirstButtonLoading = false
                }
            }
        }
    }
    
    
    static func setupAVPlayer(lightVideoName: String, lightVideoExtension: String, darkVideoName: String, darkVideoExtension: String, colorScheme: ColorScheme) -> AVPlayer {
        AVPlayer(url: Bundle.main.url(
            forResource: colorScheme == .light ? lightVideoName : darkVideoName,
            withExtension: colorScheme == .light ? lightVideoExtension : darkVideoExtension)!)
    }
    
}

#Preview {
    IntroPresenterView(
        isShowing: .constant(true))
        .environmentObject(PremiumUpdater())
        .environmentObject(ProductUpdater())
}
