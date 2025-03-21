//
//  TikAPIGetVideoInfoResponse.swift
//  ChefApp-SwiftUI
//
//  Created by Alex Coundouriotis on 12/20/24.
//

import Foundation

struct TikAPIGetVideoInfoResponse: Codable {
    
    // MARK: - Body
    struct Body: Codable {
        let apiResponse: APIResponse
        
        enum CodingKeys: String, CodingKey {
            case apiResponse
        }
    }
    
    // MARK: - Root Response
    struct APIResponse: Codable {
        let other: Other?
        let extra: Extra?
        let itemInfo: ItemInfo?
        let logPb: LogPb?
        let message: String?
        let shareMeta: ShareMeta?
        let status: String?
        let statusCode: Int?
        let status_code: Int?
        let status_msg: String?
        
        enum CodingKeys: String, CodingKey {
            case other = "$other"
            case extra
            case itemInfo
            case logPb = "log_pb"
            case message
            case shareMeta
            case status
            case statusCode
            case status_code
            case status_msg
        }
    }

    // MARK: - Other
    struct Other: Codable {
        let videoLinkHeaders: VideoLinkHeaders?
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
        let fatalItemIDs: [String]?
        let logid: String?
        let now: Int?
        
        enum CodingKeys: String, CodingKey {
            case fatalItemIDs = "fatal_item_ids"
            case logid
            case now
        }
    }

    // MARK: - ItemInfo
    struct ItemInfo: Codable {
        let itemStruct: ItemStruct?
    }

    // MARK: - ItemStruct
    struct ItemStruct: Codable {
        let aigcDescription: String?
        let baInfo: String?
        let categoryType: Int?
        let adAuthorization: Bool?
        let adLabelVersion: Int?
        let aigcLabelType: Int?
        let author: Author?
        let authorStats: AuthorStats?
        let collected: Bool?
        let contents: [Content]?
        let createTime: Int?
        let desc: String?
        let digged: Bool?
        let diversificationId: Int?
        let duetDisplay: Int?
        let duetEnabled: Bool?
        let duetInfo: DuetInfo?
        let forFriend: Bool?
        let id: String?
        let isActivityItem: Bool?
        let isAd: Bool?
        let itemCommentStatus: Int?
        let itemMute: Bool?
        let music: Music?
        let officalItem: Bool?
        let originalItem: Bool?
        let playlistId: String?
        let privateItem: Bool?
        let secret: Bool?
        let shareEnabled: Bool?
        let showNotPass: Bool?
        let stats: Stats?
        let statsV2: StatsV2?
        let stitchDisplay: Int?
        let stitchEnabled: Bool?
        let textLanguage: String?
        let textTranslatable: Bool?
        let video: Video?
        let vl1: Bool?
        
        enum CodingKeys: String, CodingKey {
            case aigcDescription = "AIGCDescription"
            case baInfo = "BAInfo"
            case categoryType
            case adAuthorization
            case adLabelVersion
            case aigcLabelType
            case author
            case authorStats
            case collected
            case contents
            case createTime
            case desc
            case digged
            case diversificationId
            case duetDisplay
            case duetEnabled
            case duetInfo
            case forFriend
            case id
            case isActivityItem
            case isAd
            case itemCommentStatus
            case itemMute
            case music
            case officalItem
            case originalItem
            case playlistId
            case privateItem
            case secret
            case shareEnabled
            case showNotPass
            case stats
            case statsV2
            case stitchDisplay
            case stitchEnabled
            case textLanguage
            case textTranslatable
            case video
            case vl1
        }
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
        let isADVirtual: Bool?
        let isEmbedBanned: Bool?
        let nickname: String?
        let openFavorite: Bool?
        let privateAccount: Bool?
        let relation: Int?
        let secUid: String?
        let secret: Bool?
        let signature: String?
        let stitchSetting: Int?
        let ttSeller: Bool?
        let uniqueId: String?
        let verified: Bool?
        
        enum CodingKeys: String, CodingKey {
            case avatarLarger
            case avatarMedium
            case avatarThumb
            case commentSetting
            case downloadSetting
            case duetSetting
            case ftc
            case id
            case isADVirtual
            case isEmbedBanned
            case nickname
            case openFavorite
            case privateAccount
            case relation
            case secUid
            case secret
            case signature
            case stitchSetting
            case ttSeller
            case uniqueId
            case verified
        }
    }

    // MARK: - AuthorStats
    struct AuthorStats: Codable {
        let diggCount: Int?
        let followerCount: Int?
        let followingCount: Int?
        let friendCount: Int?
        let heart: Int?
        let heartCount: Int?
        let videoCount: Int?
    }

    // MARK: - Content
    struct Content: Codable {
        let desc: String?
    }

    // MARK: - DuetInfo
    struct DuetInfo: Codable {
        let duetFromId: String?
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
        let isCopyrighted: Bool?
        let original: Bool?
        let playUrl: String?
        let title: String?
    }

    // MARK: - Stats
    struct Stats: Codable {
        let collectCount: Int?
        let commentCount: Int?
        let diggCount: Int?
        let playCount: Int?
        let shareCount: Int?
    }

    // MARK: - StatsV2
    struct StatsV2: Codable {
        let collectCount: String?
        let commentCount: String?
        let diggCount: String?
        let playCount: String?
        let repostCount: String?
        let shareCount: String?
        
        enum CodingKeys: String, CodingKey {
            case collectCount
            case commentCount
            case diggCount
            case playCount
            case repostCount
            case shareCount
        }
    }

    // MARK: - Video
    struct Video: Codable {
        let vqScore: String?
        let bitrate: Int?
        let claInfo: ClaInfo?
        let codecType: String?
        let cover: String?
        let definition: String?
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
        let size: Int?
        let videoQuality: String?
        let volumeInfo: VolumeInfo?
        let width: Int?
        let zoomCover: ZoomCover?
        
        enum CodingKeys: String, CodingKey {
            case vqScore = "VQScore"
            case bitrate
            case claInfo
            case codecType
            case cover
            case definition
            case downloadAddr
            case duration
            case dynamicCover
            case encodeUserTag
            case encodedType
            case format
            case height
            case id
            case originCover
            case playAddr
            case ratio
            case reflowCover
            case shareCover
            case size
            case videoQuality
            case volumeInfo
            case width
            case zoomCover
        }
    }

    // MARK: - ClaInfo
    struct ClaInfo: Codable {
        let enableAutoCaption: Bool?
        let hasOriginalAudio: Bool?
        let noCaptionReason: Int?
        
        enum CodingKeys: String, CodingKey {
            case enableAutoCaption
            case hasOriginalAudio
            case noCaptionReason
        }
    }

    // MARK: - VolumeInfo
    struct VolumeInfo: Codable {
        let loudness: Double?
        let peak: Double?
        
        enum CodingKeys: String, CodingKey {
            case loudness = "Loudness"
            case peak = "Peak"
        }
    }

    // MARK: - ZoomCover
    struct ZoomCover: Codable {
        let p240: String?
        let p480: String?
        let p720: String?
        let p960: String?
        
        enum CodingKeys: String, CodingKey {
            case p240 = "240"
            case p480 = "480"
            case p720 = "720"
            case p960 = "960"
        }
    }

    // MARK: - LogPb
    struct LogPb: Codable {
        let imprID: String?
        
        enum CodingKeys: String, CodingKey {
            case imprID = "impr_id"
        }
    }

    // MARK: - ShareMeta
    struct ShareMeta: Codable {
        let desc: String?
        let title: String?
    }
    
    let body: Body
    let success: Int
    
    enum CodingKeys: String, CodingKey {
        case success = "Success"
        case body = "Body"
    }
    
}
