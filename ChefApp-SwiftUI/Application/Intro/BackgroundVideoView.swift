//
//  BackgroundVideoView.swift
//  WriteSmith-SwiftUI
//
//  Created by Alex Coundouriotis on 3/2/24.
//

import _AVKit_SwiftUI
import AVFoundation
import Foundation
import SwiftUI

struct BackgroundVideoView: View {
    
    @State var imageName: String
    @State var imageExtension: String
    
    
    @State private var avPlayer: AVPlayer
    
    
    init(imageName: String, imageExtension: String) {
        self._imageName = State(initialValue: imageName)
        self._imageExtension = State(initialValue: imageExtension)
        
        self._avPlayer = State(initialValue: AVPlayer(url: Bundle.main.url(forResource: imageName, withExtension: imageExtension)!))
    }
    
    
    var body: some View {
        ZStack {
            VideoViewRepresentable(player: $avPlayer)
//                .ignoresSafeArea()
        }
    }
    
}

#Preview {
    
    BackgroundVideoView(
        imageName: "Scan Image Light",
        imageExtension: "m4v")
    
}
