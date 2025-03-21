//
//  TikTokSearchCardsView.swift
//  ChefApp-SwiftUI
//
//  Created by Alex Coundouriotis on 12/3/24.
//

import SwiftUI

struct TikTokSearchCardsView: View {
    
    let tikTokSearchResponse: TikAPISearchResponse  // or TikTokSearchRequest.Root if that's the type
    let maxCardWidth: CGFloat
    let justVideos: Bool = true

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(alignment: .top, spacing: 16) {
                ForEach(tikTokSearchResponse.body.apiResponse.itemList.indices, id: \.self) { index in
                    let item = tikTokSearchResponse.body.apiResponse.itemList[index]
                    let videoLinkHeaders = tikTokSearchResponse.body.apiResponse.other.videoLinkHeaders
//                    TikTokVideoCardView(tikTokSearchResponseItem: item, videoLinkHeaders: videoLinkHeaders, justVideos: justVideos)
                    TikTokVideoCardView(
                        videoCoverURLString: item.video?.cover,
                        videoPlayAddr: item.video?.playAddr,
                        videoLinkHeadersCookie: videoLinkHeaders.cookie,
                        videoLinkHeadersOrigin: videoLinkHeaders.origin,
                        videoLinkHeadersReferer: videoLinkHeaders.referer,
                        authorNickname: item.author?.nickname,
                        avatarURLString: item.author?.avatarThumb,
                        desc: item.desc,
                        playCount: item.stats?.playCount,
                        diggCount: item.stats?.diggCount,
                        commentCount: item.stats?.commentCount,
                        shareCount: item.stats?.shareCount,
                        videoDuration: item.video?.duration,
                        authorID: item.author?.id,
                        videoID: item.video?.id,
                        justVideos: justVideos)
                        .frame(maxWidth: maxCardWidth)
                }
            }
            .padding(.horizontal)
        }
    }
}

//#Preview {
//    
//    TikTokSearchCardsView()
//
//}
