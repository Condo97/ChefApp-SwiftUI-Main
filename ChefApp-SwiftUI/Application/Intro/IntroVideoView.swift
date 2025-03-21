//
//  IntroVideoView.swift
//  WriteSmith-SwiftUI
//
//  Created by Alex Coundouriotis on 3/2/24.
//

import AVKit
import Foundation
import SwiftUI
import UIKit

struct IntroVideoView<Content: View>: View {
    
    @Binding var avPlayer: AVPlayer
    @State var showReplayDelay: CGFloat
    @State var videoAspectRatio: CGFloat
    @ViewBuilder var destination: ()->Content
    
    
    @Environment(\.colorScheme) private var colorScheme
    
    private let blurryOverlayImageName = Constants.ImageName.blurryOverlay
    
    @State private var isDisplayingReplayButton: Bool = false
    
    @State private var isShowingNext: Bool = false
    
    
//    var videoViewRepresentableTopPadding: CGFloat {
//        get {
    //            let additionalOffset = UIScreen.screenWidth < 388 ? 50.0 : 0.0
//            // Get device width and height, multiply device width by aspect ratio, subtract product from device height to get top padding if positive otherwise zero
//            print(UIScreen.screenWidth)
//            let topPadding = UIScreen.screenWidth * (1 / videoAspectRatio) - UIScreen.screenHeight - additionalOffset
//            
//            if topPadding < 0 {
//                return 0
//            }
//            
//            return topPadding
//        }
//    }
    
    
    var body: some View {
        ZStack {
            // Background Video View
//            BackgroundVideoView(
//                imageName: colorScheme == .light ? lightModeVideoName : darkModeVideoName,
//                imageExtension: colorScheme == .light ? lightModeVideoExtension : darkModeVideoExtension)
            Colors.videoMatchedColor
            
            ZStack {
                VideoViewRepresentable(player: $avPlayer)
//                    .padding(.top, -50)
            }
            .aspectRatio(videoAspectRatio, contentMode: .fit)
//            .padding(.top, videoViewRepresentableTopPadding)
        }
        .ignoresSafeArea()
        .toolbar(.hidden, for: .navigationBar)
        .navigationDestination(isPresented: $isShowingNext, destination: destination)
        .background(Colors.secondaryBackground)
        .overlay(alignment: .bottom) {
            
            // Button within container with blurry overlay background
            VStack {
                //                let additionalYOffset = 80.0
                Spacer()
                
                //                ZStack {
                //                    Image(blurryOverlayImageName)
                //                        .resizable()
                //                        .frame(height: 400)
                //                        .offset(y: 18)
                //                        .foregroundStyle(Colors.secondaryBackground)
                
                VStack(spacing: 0.0) {
                    if isDisplayingReplayButton {
                        Button(action: {
                            HapticHelper.doSuccessHaptic()
                            
                            resetAVPlayer()
                            playVideo()
                        }) {
                            Text("\(Image(systemName: "arrow.triangle.2.circlepath")) Replay")
                                .font(.custom(Constants.FontName.body, size: 17.0))
                                .foregroundStyle(Colors.foregroundText)
                        }
                        
                    }
                    Button(action: {
                        // Do light haptic
                        HapticHelper.doLightHaptic()
                        
                        // Pause avPlayer
                        avPlayer.pause()
                        
                        // Show next view
                        isShowingNext = true
                    }) {
                        ZStack {
                            Text("Next...")
                                .font(.custom(Constants.FontName.heavy, size: 24.0))
                            
                            HStack {
                                Spacer()
                                Text(Image(systemName: "chevron.right"))
                            }
                        }
                    }
                    .padding()
                    .foregroundStyle(Colors.foregroundText)
                    //                    .foregroundStyle(Colors.elementBackgroundColor)
                    .background(Colors.background)
                    //                    .background(Colors.foreground)
                    .clipShape(RoundedRectangle(cornerRadius: Constants.UI.cornerRadius))
                    .bounceable()
                    .padding()
                    //                    .padding(.top, blurryOverlayImageYOffset + buttonYOffset)
                    //                    .padding()
                    //                    .padding(.top, -48)
                }
                .padding(.bottom)
                
                //                }
                //                .offset(y: UIScreen.screenHeight / 2 - additionalYOffset)
            }
        }
        .onAppear {
            playVideo()
        }
    }
    
    
    func resetAVPlayer() {
        self.avPlayer.pause()
        self.avPlayer.seek(to: .zero)
        self.isDisplayingReplayButton = false
    }
    
    func playVideo() {
        DispatchQueue.main.async {
//            self.avPlayer = IntroVideoView.setupAVPlayer(
//                lightVideoName: lightVideoName,
//                lightVideoExtension: lightVideoExtension,
//                darkVideoName: darkVideoName,
//                darkVideoExtension: darkVideoExtension,
//                colorScheme: colorScheme)
            
            self.avPlayer.play()
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + showReplayDelay) {
            withAnimation {
                self.isDisplayingReplayButton = true
            }
        }
        
    }
    
}

#Preview {
    
    func setupAVPlayer(lightVideoName: String, lightVideoExtension: String, darkVideoName: String, darkVideoExtension: String, colorScheme: ColorScheme) -> AVPlayer {
        AVPlayer(url: Bundle.main.url(
            forResource: colorScheme == .light ? lightVideoName : darkVideoName,
            withExtension: colorScheme == .light ? lightVideoExtension : darkVideoExtension)!)
    }
    
//    let avPlayer = AVPlayer(url: Bundle.main.url(forResource: "Intro New 1 Light", withExtension: "mp4")!)
    
    return IntroVideoView(
        avPlayer: .constant(
            setupAVPlayer(
                lightVideoName: "Intro New 1 Light",
                lightVideoExtension: "mp4",
                darkVideoName: "Intro New 1 Dark",
                darkVideoExtension: "mp4",
                colorScheme: .light)),
        showReplayDelay: 2.0,
        videoAspectRatio: 1284.0/2778.0,
        destination: {
        
    })
    
}
