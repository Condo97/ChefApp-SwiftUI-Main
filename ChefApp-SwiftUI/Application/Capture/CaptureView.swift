//
//  CaptureView.swift
//  SeeGPT
//
//  Created by Alex Coundouriotis on 3/5/24.
//

import AVFoundation
import Foundation
import SwiftUI

struct CaptureView: View {
    
    @StateObject var model: CaptureModel = CaptureModel()
    
    private static let initialChatText: String = "Tell me about this image."
    
    
    @EnvironmentObject private var premiumUpdater: PremiumUpdater
    @EnvironmentObject private var remainingUpdater: RemainingUpdater
    
    @Environment(\.managedObjectContext) private var viewContext
    
    @State private var isShowingDetailView: Bool = false
    
    @State private var resetCaptureView: Bool = false
    
    var body: some View {
        ZStack {
            CaptureCameraViewControllerRepresentable(
//                isShowing: .constant(true),
//                isLoading: $captureChatGenerator.isLoading,
                reset: $resetCaptureView,
                onAttach: { image, cropFrame, unmodifiedImage in
                    
                })
//            .onReceive(captureChatGenerator.$isLoading, perform: { isLoading in
//                if isLoading {
//                    // Show detailView on receive true from isGenerating
//                    isShowingDetailView = true
//                }
//            })
        }
        .ignoresSafeArea()
        .navigationTitle("")
    }
    
}

#Preview {
    
//    TabBar()
    CaptureView()
    
}
