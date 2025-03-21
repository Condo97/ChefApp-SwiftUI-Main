//
//  TikTokGetVideoInfoCardView.swift
//  ChefApp-SwiftUI
//
//  Created by Alex Coundouriotis on 12/20/24.
//

import SwiftUI

struct TikTokGetVideoInfoCardView: View {
    
    let tikAPIGetVideoInfoResponse: TikAPIGetVideoInfoResponse
    
    var item: TikAPIGetVideoInfoResponse.ItemStruct? {
        tikAPIGetVideoInfoResponse.body.apiResponse.itemInfo?.itemStruct
    }
    
    var body: some View {
        VStack {
            TikTokVideoCardView(
                videoCoverURLString: item?.video?.cover,
                videoPlayAddr: item?.video?.playAddr,
                videoLinkHeadersCookie: tikAPIGetVideoInfoResponse.body.apiResponse.other?.videoLinkHeaders?.cookie,
                videoLinkHeadersOrigin: tikAPIGetVideoInfoResponse.body.apiResponse.other?.videoLinkHeaders?.origin,
                videoLinkHeadersReferer: tikAPIGetVideoInfoResponse.body.apiResponse.other?.videoLinkHeaders?.referer,
                authorNickname: item?.author?.nickname,
                avatarURLString: item?.author?.avatarThumb,
                desc: item?.desc,
                playCount: item?.stats?.playCount,
                diggCount: item?.stats?.diggCount,
                commentCount: item?.stats?.commentCount,
                shareCount: item?.stats?.shareCount,
                videoDuration: item?.video?.duration,
                authorID: item?.author?.id,
                videoID: item?.video?.id,
                justVideos: true)
        }
    }
    
}

//#Preview {
//    
//    TikTokGetVideoInfoCardView()
//    
//}
