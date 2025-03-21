//
//  PostContainer.swift
//  SocialBackup
//
//  Created by Alex Coundouriotis on 10/11/24.
//

import AVKit
import SwiftUI

// Custom PreferenceKey to track scroll offset
struct ScrollOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value += nextValue()
    }
}

struct PostContainer: View {
//    let tikTokSearchResponseItem: TikAPISearchResponse.Item  // Using Item from TikTokSearchResponse
//    let videoLinkHeaders: TikAPISearchResponse.VideoLinkHeaders
    let videoPlayAddr: String?
    let videoLinkHeadersCookie: String?
    let videoLinkHeadersOrigin: String?
    let videoLinkHeadersReferer: String?
    let authorNickname: String?
    let avatarURLString: String?
    let desc: String?
    let playCount: Int?
    let diggCount: Int?
    let commentCount: Int?
    let shareCount: Int?
    let videoDuration: Int?
    let authorID: String?
    let videoID: String?
    
    @Binding var isPresented: Bool

    @State private var translation: CGFloat = 0
    @State private var scrollOffset: CGFloat = 0
    @State private var initialDragGestureScrollOffset: CGFloat?

    @State private var isShowingAddToCollection: Bool = false

    @State private var player: AVPlayer?

    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack(spacing: 0.0) {
                    // Reference view to track scroll offset
                    Color.clear
                        .frame(height: 0)
                        .background(
                            GeometryReader { inner in
                                Color.clear.preference(key: ScrollOffsetPreferenceKey.self, value: inner.frame(in: .global).origin.y)
                            }
                        )
                        .overlay(alignment: .topTrailing) {
                            Button(action: { isPresented = false }) {
                                Image(systemName: "xmark")
                                    .font(.body, 17.0)
                                    .foregroundStyle(Colors.elementBackground)
                            }
                        }

                    VStack {
                        // Video Content
                        if let player {
                            VideoPlayer(player: player)
                                .frame(height: geometry.size.height)
                        } else {
                            Text("Unable to load video")
                        }

                        VStack {
                            PostStatsContainer(
                                authorNickname: authorNickname,
                                avatarURLString: avatarURLString,
                                desc: desc,
                                playCount: playCount,
                                diggCount: diggCount,
                                commentCount: commentCount,
                                shareCount: shareCount,
                                videoDuration: videoDuration,
                                authorID: authorID,
                                videoID: videoID)
                            Spacer(minLength: 100.0)
                        }
                        .background(Colors.background)
                    }
                }
            }
            .background(.black)
            .onPreferenceChange(ScrollOffsetPreferenceKey.self) { value in
                // Update scroll offset
                DispatchQueue.main.async {
                    self.scrollOffset = value
                }
            }
            .offset(y: self.translation)
            .simultaneousGesture(
                DragGesture()
                    .onChanged { value in
                        if initialDragGestureScrollOffset == nil {
                            initialDragGestureScrollOffset = scrollOffset
                        }

                        let totalHeight = value.translation.height + (self.initialDragGestureScrollOffset ?? 0.0)
                        if totalHeight > 0 {
                            // Update translation only if dragging down and at top
                            self.translation = totalHeight
                        }
                    }
                    .onEnded { value in
                        initialDragGestureScrollOffset = nil

                        if self.translation > 100 {
                            // Dismiss the view when dragged down sufficiently
                            withAnimation {
                                self.isPresented = false
                            }
                        } else {
                            // Animate back to original position
                            withAnimation {
                                self.translation = 0
                            }
                        }
                    }
            )
        }
        .ignoresSafeArea()
        .onAppear {
            // Prepare player
            if let playURLString = videoPlayAddr,
               let playURL = URL(string: playURLString) {

                // Prepare HTTP headers
                var headers = [String: String]()

                // Get the cookie from the response
                if let cookie = videoLinkHeadersCookie {
                    headers["Cookie"] = cookie
                }
                if let origin = videoLinkHeadersOrigin {
                    headers["Origin"] = origin
                }
                if let referer = videoLinkHeadersReferer {
                    headers["Referer"] = referer
                }

//                // Optional: Add other headers if required (e.g., "User-Agent", "Referer", etc.)
//                if let referer = videoLinkHeaders.referer {
//                    headers["Referer"] = referer
//                }
//
//                if let origin = videoLinkHeaders.origin {
//                    headers["Origin"] = origin
//                }

                // Create AVURLAsset with custom headers
                let asset = AVURLAsset(url: playURL, options: ["AVURLAssetHTTPHeaderFieldsKey": headers])

                // Create AVPlayerItem
                let playerItem = AVPlayerItem(asset: asset)

                // Create AVPlayer
                self.player = AVPlayer(playerItem: playerItem)

                // Start playing
                self.player?.play()
            }
        }
        .onDisappear {
            self.player?.pause()
        }
        // .addPostToCollectionFullScreenCover(isPresented: $isShowingAddToCollection, post: post) // Adjust or remove as needed
    }
}
