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
                reset: $resetCaptureView,
                onAttach: { image, cropFrame, unmodifiedImage in
                    
                })
        }
        .ignoresSafeArea()
        .navigationTitle("")
    }
    
}

#Preview {
    
//    TabBar()
    CaptureView()
    
}
