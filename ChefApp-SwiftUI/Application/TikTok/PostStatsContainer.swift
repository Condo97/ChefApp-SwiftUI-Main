//
//  PostStatsContainer.swift
//  SocialBackup
//
//  Created by Alex Coundouriotis on 10/11/24.
//

import SwiftUI

struct PostStatsContainer: View {
    
//    var tikTokSearchResponseItem: TikAPISearchResponse.Item
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
    
    @Environment(\.managedObjectContext) private var viewContext
    
//    @State private var postInfo: GetPostInfoResponse?
//    @State private var postTranscriptions: [String] = []
    
    @State private var isLoading: Bool = false
    
    @State private var isLoadingSummary: Bool = false
    
    @State private var isShowingTranscriptions: Bool = false
    @State private var isShowingUltra: Bool = false
    
    var body: some View {
        Group {
            PostStatsView(
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
        }
        .ultraViewPopover(isPresented: $isShowingUltra)
    }
    
}

//#Preview {
//    
//    PostStatsContainer()
//
//}
