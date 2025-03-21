//
//  VideoViewRepresentable.swift
//  WriteSmith-SwiftUI
//
//  Created by Alex Coundouriotis on 3/2/24.
//

import AVKit
import Foundation
import SwiftUI

struct VideoViewRepresentable : UIViewControllerRepresentable {
    
    @Binding var player: AVPlayer
    
    init(player: Binding<AVPlayer>) {
        self._player = player
    }
    
    func makeUIViewController(context: Context) -> AVPlayerViewController {
//        let controller = AVPlayerViewController()
//        controller.player = player
//        controller.showsPlaybackControls = false
        
//        player.play()
        let controller = AVPlayerViewController()
        controller.player = self.player
        controller.showsPlaybackControls = false
        
        controller.videoGravity = .resizeAspectFill
        
        return controller
    }
    
    func updateUIViewController(_ uiViewController: AVPlayerViewController, context: Context) {
//        let controller = AVPlayerViewController()
        uiViewController.player = player
//        controller.showsPlaybackControls = false
        
//        player.play()
        
//        return controller
    }
    
}
