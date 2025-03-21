//
//  TikAPISearchResponse.swift
//  ChefApp-SwiftUI
//
//  Created by Alex Coundouriotis on 12/2/24.
//

import Foundation

struct TikAPISearchResponse: Codable {
    
    // MARK: - Body
    struct Body: Codable {
        let apiResponse: APIResponse
        
        enum CodingKeys: String, CodingKey {
            case apiResponse
        }
    }
    
    // MARK: - APIResponse
    struct APIResponse: Codable {
        let other: Other
        let extra: Extra?
        let hasMore: Int?
        let itemList: [Item]
        
        enum CodingKeys: String, CodingKey {
            case other = "$other"
            case extra
            case hasMore = "has_more"
            case itemList = "item_list"
        }
    }
    
    // MARK: - Other
    struct Other: Codable {
        let videoLinkHeaders: VideoLinkHeaders
        
        enum CodingKeys: String, CodingKey {
            case videoLinkHeaders
        }
    }
    
    // MARK: - VideoLinkHeaders
    struct VideoLinkHeaders: Codable {
        let cookie: String?
        let origin: String?
        let referer: String?
        
        enum CodingKeys: String, CodingKey {
            case cookie = "Cookie"
            case origin = "Origin"
            case referer = "Referer"
        }
    }
    
    // MARK: - Extra
    struct Extra: Codable {
        let apiDebugInfo: String?
        let fatalItemIds: [String]?
        let logid: String?
        let now: Int?
        let searchRequestId: String?
        
        enum CodingKeys: String, CodingKey {
            case apiDebugInfo = "api_debug_info"
            case fatalItemIds = "fatal_item_ids"
            case logid
            case now
            case searchRequestId = "search_request_id"
        }
    }
    
    // MARK: - Item
    struct Item: Codable {
        let author: Author?
        let authorStats: AuthorStats?
        let challenges: [Challenge]?
        let collected: Bool?
        let createTime: Int?
        let desc: String?
        let digged: Bool?
        let duetEnabled: Bool?
        let duetInfo: DuetInfo?
        let forFriend: Bool?
        let id: String?
        let isAd: Bool?
        let itemCommentStatus: Int?
        let itemMute: Bool?
        let music: Music?
        let officalItem: Bool?
        let originalItem: Bool?
        let privateItem: Bool?
        let secret: Bool?
        let shareEnabled: Bool?
        let showNotPass: Bool?
        let stats: Stats?
        let stickersOnItem: [Sticker]?
        let stitchEnabled: Bool?
        let textExtra: [TextExtra]?
        let video: Video?
        let vl1: Bool?
        let anchors: [Anchor]?
        
        // If any keys don't match the property names, add CodingKeys here
    }
    
    // MARK: - Author
    struct Author: Codable {
        let avatarLarger: String?
        let avatarMedium: String?
        let avatarThumb: String?
        let commentSetting: Int?
        let downloadSetting: Int?
        let duetSetting: Int?
        let ftc: Bool?
        let id: String?
        let nickname: String?
        let openFavorite: Bool?
        let privateAccount: Bool?
        let relation: Int?
        let secUid: String?
        let secret: Bool?
        let signature: String?
        let stitchSetting: Int?
        let uniqueId: String?
        let verified: Bool?
        
        // Add CodingKeys if necessary
    }
    
    // MARK: - AuthorStats
    struct AuthorStats: Codable {
        let diggCount: Int?
        let followerCount: Int?
        let followingCount: Int?
        let heart: Int?
        let heartCount: Int?
        let videoCount: Int?
        
        // Add CodingKeys if necessary
    }
    
    // MARK: - Challenge
    struct Challenge: Codable {
        let coverLarger: String?
        let coverMedium: String?
        let coverThumb: String?
        let desc: String?
        let id: String?
        let isCommerce: Bool?
        let profileLarger: String?
        let profileMedium: String?
        let profileThumb: String?
        let title: String?
        
        // Add CodingKeys if necessary
    }
    
    // MARK: - DuetInfo
    struct DuetInfo: Codable {
        let duetFromId: String?
        
        enum CodingKeys: String, CodingKey {
            case duetFromId
        }
    }
    
    // MARK: - Music
    struct Music: Codable {
        let album: String?
        let authorName: String?
        let coverLarge: String?
        let coverMedium: String?
        let coverThumb: String?
        let duration: Int?
        let id: String?
        let original: Bool?
        let playUrl: String?
        let title: String?
        
        // Add CodingKeys if necessary
    }
    
    // MARK: - Stats
    struct Stats: Codable {
        let collectCount: Int?
        let commentCount: Int?
        let diggCount: Int?
        let playCount: Int?
        let shareCount: Int?
        
        // Add CodingKeys if necessary
    }
    
    // MARK: - Sticker
    struct Sticker: Codable {
        let stickerText: [String]?
        let stickerType: Int?
        
        // Add CodingKeys if necessary
    }
    
    // MARK: - TextExtra
    struct TextExtra: Codable {
        let awemeId: String?
        let end: Int?
        let hashtagId: String?
        let hashtagName: String?
        let isCommerce: Bool?
        let secUid: String?
        let start: Int?
        let subType: Int?
        let type: Int?
        let userId: String?
        let userUniqueId: String?
        
        // Add CodingKeys if necessary
    }
    
    // MARK: - Video
    struct Video: Codable {
        let bitrate: Int?
        let cover: String?
        let downloadAddr: String?
        let duration: Int?
        let dynamicCover: String?
        let encodeUserTag: String?
        let encodedType: String?
        let format: String?
        let height: Int?
        let id: String?
        let originCover: String?
        let playAddr: String?
        let ratio: String?
        let reflowCover: String?
        let shareCover: [String]?
        let videoQuality: String?
        let width: Int?
        
        // Add CodingKeys if necessary
    }
    
    // MARK: - Anchor
    struct Anchor: Codable {
        let description: String?
        let extraInfo: ExtraInfo?
        let icon: Icon?
        let id: String?
        let keyword: String?
        let logExtra: String?
        let schema: String?
        let thumbnail: Thumbnail?
        let type: Int?
    }
    
    // MARK: - ExtraInfo
    struct ExtraInfo: Codable {
        let subtype: String?
    }
    
    // MARK: - Icon
    struct Icon: Codable {
        let urlList: [String]?
    }
    
    // MARK: - Thumbnail
    struct Thumbnail: Codable {
        let height: Int?
        let urlList: [String]?
        let width: Int?
    }
    
    let body: Body
    let success: Int
    
    enum CodingKeys: String, CodingKey {
        case success = "Success"
        case body = "Body"
    }
    
}
