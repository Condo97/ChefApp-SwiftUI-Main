//
//  TikTokVideoCardView.swift
//  ChefApp-SwiftUI
//
//  Created by Alex Coundouriotis on 12/3/24.
//

import SwiftUI

struct TikTokVideoCardView: View {
    
//    let tikTokSearchResponseItem: TikAPISearchResponse.Item
//    let videoLinkHeaders: TikAPISearchResponse.VideoLinkHeaders
    let videoCoverURLString: String?
    
    let videoPlayAddr: String?
    let videoLinkHeadersCookie: String?
    let videoLinkHeadersOrigin: String?
    let videoLinkHeadersReferer: String?
    
    let authorNickname: String?
    let avatarURLString: String? // Avatar thumbnail
    let desc: String?
    let playCount: Int?
    let diggCount: Int?
    let commentCount: Int?
    let shareCount: Int?
    let videoDuration: Int?
    let authorID: String?
    let videoID: String?
    
    let justVideos: Bool
    
    @State private var isPresentingVideo = false
    
    var body: some View {
        VStack(alignment: .leading) {
            // Video Cover Image
            if let videoCoverURLString, let coverURL = URL(string: videoCoverURLString) {
                AsyncImage(url: coverURL) { image in
                    image.resizable()
                         .aspectRatio(contentMode: .fit)
                } placeholder: {
                    Color.gray.opacity(0.3)
                }
//                .frame(width: 200, height: 300)
                .clipped()
                .cornerRadius(14)
                .onTapGesture {
                    isPresentingVideo = true
                }
                // Present the full-screen video view
                .fullScreenCover(isPresented: $isPresentingVideo) {
                    PostContainer(
                        videoPlayAddr: videoPlayAddr,
                        videoLinkHeadersCookie: videoLinkHeadersCookie,
                        videoLinkHeadersOrigin: videoLinkHeadersOrigin,
                        videoLinkHeadersReferer: videoLinkHeadersReferer,
                        authorNickname: authorNickname,
                        avatarURLString: avatarURLString,
                        desc: desc,
                        playCount: playCount,
                        diggCount: diggCount,
                        commentCount: commentCount,
                        shareCount: shareCount,
                        videoDuration: videoDuration,
                        authorID: authorID,
                        videoID: videoID,
                        isPresented: $isPresentingVideo)
                }
            } else {
                // Placeholder if no cover image
                Color.gray.opacity(0.3)
//                    .frame(width: 200, height: 300)
                    .cornerRadius(14)
            }
            
            if !justVideos {
                // The rest of the view remains the same...
                // [Description, Author Info, Stats]
                Text(desc ?? "No Description")
                    .font(.body, 14.0)
                    .lineLimit(2)
                    .padding(.top, 8)
                
                HStack {
                    // Author Avatar
                    if let avatarURLString, let avatarURL = URL(string: avatarURLString) {
                        AsyncImage(url: avatarURL) { image in
                            image.resizable()
                                .aspectRatio(contentMode: .fill)
                        } placeholder: {
                            Circle()
                                .fill(Color.gray.opacity(0.3))
                        }
                        .frame(width: 30, height: 30)
                        .clipShape(Circle())
                    } else {
                        Circle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(width: 30, height: 30)
                    }
                    
                    Text(authorNickname ?? "Unknown Author")
                        .font(.body, 14.0)
                }
                .padding(.top, 4)
                
                if let playCount {
                    Label("\(playCount)", systemImage: "play.fill")
                        .font(.body, 14.0)
                        .foregroundColor(Colors.foregroundText)
                        .opacity(0.6)
                }
                HStack(spacing: 16) {
                    if let commentCount {
                        Label("\(commentCount)", systemImage: "message.fill")
                    }
                    if let diggCount {
                        Label("\(diggCount)", systemImage: "heart.fill")
                    }
                }
                .font(.body, 14.0)
                .foregroundColor(Colors.foregroundText)
                .opacity(0.6)
            }
        }
//        .frame(width: 200)
    }
}
