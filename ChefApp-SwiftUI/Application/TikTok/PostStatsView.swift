//
//  PostStatsView.swift
//  SocialBackup
//
//  Created by Alex Coundouriotis on 10/11/24.
//

import SwiftUI

struct PostStatsView: View {
    
//    var tikTokSearchResponseItem: TikAPISearchResponse.Item  // Using Item from TikTokSearchResponse
//    let author: String?
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
    

    @Environment(\.openURL) private var openURL

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Author Info
//                if let author = author {
                HStack(spacing: 12) {
                    // Author Avatar
                    if let avatarURLString, let avatarURL = URL(string: avatarURLString) {
                        Button(action: {
                            if let authorID,
                               let profileURL = URL(string: "https://tiktok.com/@\(authorID)") {
                                openURL(profileURL)
                            }
                        }) {
                            AsyncImage(url: avatarURL) { image in
                                image.resizable()
                                    .aspectRatio(contentMode: .fill)
                            } placeholder: {
                                Circle()
                                    .fill(Color.gray.opacity(0.3))
                            }
                            .frame(width: 50, height: 50)
                            .clipShape(Circle())
//                                .overlay(alignment: .bottomTrailing) {
//                                    // Source Icon (if any)
//                                    if let sourceImageName = getSourceImageName(from: tikTokSearchResponseItem) {
//                                        Image(sourceImageName)
//                                            .resizable()
//                                            .aspectRatio(contentMode: .fit)
//                                            .frame(width: 28.0, height: 28.0)
//                                            .offset(x: 6, y: 6)
//                                    }
//                                }
                        }
                    } else {
                        Circle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(width: 50, height: 50)
                    }

                    // Author Name and Username
                    VStack(alignment: .leading) {
                        Text(authorNickname ?? "Unknown Author")
                            .font(.custom(Constants.FontName.heavy, size: 17.0))
                        Text("@\(authorID ?? "")")
                            .font(.custom(Constants.FontName.body, size: 12.0))
                    }
                }
//                }

                // Post Description
                if let description = desc {
                    Text(description)
                        .font(.custom(Constants.FontName.heavy, size: 20.0))
                }

                // Post Stats
                if let playCount, let diggCount, let commentCount, let shareCount {
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], alignment: .leading) {
                        StatisticView(iconName: "play.fill", value: "\(playCount)")
                        StatisticView(iconName: "heart.fill", value: "\(diggCount)")
                        StatisticView(iconName: "bubble.right.fill", value: "\(commentCount)")
                        StatisticView(iconName: "arrowshape.turn.up.right.fill", value: "\(shareCount)")
                    }
                }
                
                // Video Duration
                if let videoDuration {
                    StatisticView(iconName: "clock.fill", value: formatDuration(Double(videoDuration)))
                }

                // Open Transcriptions View (if any)
                // Implement as needed.

//                // Tags and Challenges
//                if let challenges = tikTokSearchResponseItem.challenges {
//                    VStack(alignment: .leading, spacing: 8.0) {
//                        Text("Tags:")
//                            .font(.custom(Constants.FontName.heavy, size: 10.0))
//                        SingleAxisGeometryReader(axis: .horizontal) { geo in
//                            HStack {
//                                FlexibleView(
//                                    availableWidth: geo.magnitude,
//                                    data: challenges.compactMap { $0.title },
//                                    spacing: 8.0,
//                                    alignment: .leading,
//                                    content: { tag in
////                                        Button(action: { onSelectTag(tag) }) {
//                                            Text(tag)
//                                                .font(.custom(Constants.FontName.body, size: 14.0))
//                                                .foregroundStyle(Colors.foregroundText)
//                                                .padding(.horizontal)
//                                                .padding(.vertical, 8)
//                                                .background(Colors.foreground)
//                                                .clipShape(RoundedRectangle(cornerRadius: 14.0))
////                                        }
//                                    })
//                                Spacer()
//                            }
//                        }
//                    }
//                }

                // Video URL and Actions
//                if let videoURLString = tikTokSearchResponseItem.video?.playAddr, let videoURL = URL(string: videoURLString) {
                if let authorID,
                   let videoID,
                   let videoURL = URL(string: "https://tiktok.com/@\(authorID)/video/\(videoID)") {
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Video URL:")
                                .font(.custom(Constants.FontName.heavy, size: 14.0))
                            Text(videoURL.absoluteString)
                                .font(.body, 9.0)
                        }
                        Spacer()
                        Button(action: {
                            // Copy URL to clipboard
                            UIPasteboard.general.url = videoURL
                        }) {
                            Image(systemName: "doc.on.doc")
                                .font(.custom(Constants.FontName.body, size: 12.0))
                                .miniButtonStyle()
                        }
                        Button(action: {
                            openURL(videoURL)
                        }) {
                            HStack(spacing: 4.0) {
                                Text("Open")
                                Image(systemName: "chevron.right")
                                    .font(.custom(Constants.FontName.body, size: 10.0))
                            }
                            .miniButtonStyle()
                        }
                    }
                }
            }
            .foregroundStyle(Colors.foregroundText)
            .padding()
        }
    }

    func getSourceImageName(from item: TikAPISearchResponse.Item) -> String? {
        // Return the image name based on item source, if applicable
        return nil
    }

    // Helper function to format duration from seconds to "Xm Ys"
    func formatDuration(_ duration: Double) -> String {
        let totalSeconds = Int(duration)
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        return "\(minutes)m \(seconds)s"
    }
    
}

// Helper view for displaying statistics
struct StatisticView: View {
    var iconName: String
    var value: String

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: iconName)
                .foregroundColor(.gray)
            Text(value)
                .font(.subheadline)
                .foregroundColor(.gray)
        }
    }
    
}

// Preview for PostStatsView
struct PostStatsView_Previews: PreviewProvider {
    
    static var previews: some View {
        // Create a sample Author for preview
        let sampleAuthor = TikAPISearchResponse.Author(
            avatarLarger: "https://example.com/avatarLarger.jpg",
            avatarMedium: "https://example.com/avatarMedium.jpg",
            avatarThumb: "https://example.com/avatarThumb.jpg",
            commentSetting: 1,
            downloadSetting: 1,
            duetSetting: 1,
            ftc: false,
            id: "author123456",
            nickname: "SampleUser",
            openFavorite: true,
            privateAccount: false,
            relation: 0,
            secUid: "SECUID123456",
            secret: false,
            signature: "This is a sample signature.",
            stitchSetting: 1,
            uniqueId: "sampleuser",
            verified: true
        )
        
        // Create a sample Video for preview
        let sampleVideo = TikAPISearchResponse.Video(
            bitrate: 720,
            cover: "https://example.com/videoCover.jpg",
            downloadAddr: "https://example.com/videoDownload.mp4",
            duration: 120,
            dynamicCover: "https://example.com/dynamicCover.jpg",
            encodeUserTag: "SampleTag",
            encodedType: "mp4",
            format: "mp4",
            height: 1280,
            id: "video123456",
            originCover: "https://example.com/originCover.jpg",
            playAddr: "https://example.com/playVideo.mp4",
            ratio: "16:9",
            reflowCover: "https://example.com/reflowCover.jpg",
            shareCover: ["https://example.com/shareCover1.jpg", "https://example.com/shareCover2.jpg"],
            videoQuality: "HD",
            width: 720
        )
        
        // Create a sample Stats for preview
        let sampleStats = TikAPISearchResponse.Stats(
            collectCount: 150,
            commentCount: 75,
            diggCount: 300,
            playCount: 5000,
            shareCount: 25
        )
        
        // Create a sample AuthorStats for preview
        let sampleAuthorStats = TikAPISearchResponse.AuthorStats(
            diggCount: 400,
            followerCount: 10000,
            followingCount: 500,
            heart: 200000,
            heartCount: 250000,
            videoCount: 150
        )
        
        // Create a sample Challenge for preview
        let sampleChallenge = TikAPISearchResponse.Challenge(
            coverLarger: "https://example.com/challengeCoverLarger.jpg",
            coverMedium: "https://example.com/challengeCoverMedium.jpg",
            coverThumb: "https://example.com/challengeCoverThumb.jpg",
            desc: "Join the Sample Challenge!",
            id: "challenge123",
            isCommerce: false,
            profileLarger: "https://example.com/challengeProfileLarger.jpg",
            profileMedium: "https://example.com/challengeProfileMedium.jpg",
            profileThumb: "https://example.com/challengeProfileThumb.jpg",
            title: "SampleChallenge"
        )
        
        // Create a sample DuetInfo for preview
        let sampleDuetInfo = TikAPISearchResponse.DuetInfo(
            duetFromId: "duetFrom123456"
        )
        
        // Create a sample Music for preview
        let sampleMusic = TikAPISearchResponse.Music(
            album: "Sample Album",
            authorName: "Sample Artist",
            coverLarge: "https://example.com/musicCoverLarge.jpg",
            coverMedium: "https://example.com/musicCoverMedium.jpg",
            coverThumb: "https://example.com/musicCoverThumb.jpg",
            duration: 180,
            id: "music123456",
            original: true,
            playUrl: "https://example.com/musicPlay.mp3",
            title: "Sample Music Title"
        )
        
        // Create a sample Sticker for preview
        let sampleSticker = TikAPISearchResponse.Sticker(
            stickerText: ["Sample Sticker"],
            stickerType: 1
        )
        
        // Create a sample TextExtra for preview
        let sampleTextExtra = TikAPISearchResponse.TextExtra(
            awemeId: "aweme123456",
            end: 50,
            hashtagId: "hashtag123",
            hashtagName: "SampleHashtag",
            isCommerce: false,
            secUid: "secUid123456",
            start: 0,
            subType: 1,
            type: 1,
            userId: "user123456",
            userUniqueId: "uniqueuser123"
        )
        
        // Create a sample Anchor for preview
        let sampleAnchor = TikAPISearchResponse.Anchor(
            description: "This is a sample anchor description.",
            extraInfo: TikAPISearchResponse.ExtraInfo(subtype: "subtype1"),
            icon: TikAPISearchResponse.Icon(urlList: ["https://example.com/icon1.jpg"]),
            id: "anchor123",
            keyword: "SampleKeyword",
            logExtra: "SampleLogExtra",
            schema: "sampleSchema",
            thumbnail: TikAPISearchResponse.Thumbnail(
                height: 100,
                urlList: ["https://example.com/thumbnail1.jpg"],
                width: 100
            ),
            type: 1
        )
        
        // Create the sample Item with all fields populated
        let sampleItem = TikAPISearchResponse.Item(
            author: sampleAuthor,
            authorStats: sampleAuthorStats,
            challenges: [sampleChallenge],
            collected: true,
            createTime: 1700000000, // Example timestamp
            desc: "This is a sample description for the TikTok video.",
            digged: true,
            duetEnabled: true,
            duetInfo: sampleDuetInfo,
            forFriend: false,
            id: "item123456",
            isAd: false,
            itemCommentStatus: 1,
            itemMute: false,
            music: sampleMusic,
            officalItem: false,
            originalItem: true,
            privateItem: false,
            secret: false,
            shareEnabled: true,
            showNotPass: false,
            stats: sampleStats,
            stickersOnItem: [sampleSticker],
            stitchEnabled: true,
            textExtra: [sampleTextExtra],
            video: sampleVideo,
            vl1: false,
            anchors: [sampleAnchor]
        )
        
        PostStatsView(
            authorNickname: sampleItem.author?.nickname,
            avatarURLString: sampleItem.author?.avatarThumb,
            desc: sampleItem.desc,
            playCount: sampleItem.stats?.playCount,
            diggCount: sampleItem.stats?.diggCount,
            commentCount: sampleItem.stats?.commentCount,
            shareCount: sampleItem.stats?.shareCount,
            videoDuration: sampleItem.video?.duration,
            authorID: sampleItem.author?.id,
            videoID: sampleItem.video?.id)
        .background(Color.gray.opacity(0.1)) // Replace with Colors.background if defined
        .previewLayout(.sizeThatFits) // Adjust the preview layout as needed
    }
}
