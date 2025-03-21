//
//  TikTokSourceRecipeGenerator.swift
//  ChefApp-SwiftUI
//
//  Created by Alex Coundouriotis on 12/21/24.
//

import CoreData
import Foundation
import Speech

class TikTokTranscriber {
    
    static func transcribe(
//        tikTokVideoID: String,
        authToken: String,
        playAddr: URL,
        videoLinkHeadersCookie: String,
        videoLinkHeadersOrigin: String?,
        videoLinkHeadersReferer: String?
    ) async throws -> String? {
//        // Request speech authorization
//        await requestSpeechAuthorization()
        
        // Download video
        let localVideoData = try await downloadVideo(
            from: playAddr,
            videoLinkHeadersCookie: videoLinkHeadersCookie,
            videoLinkHeadersOrigin: videoLinkHeadersOrigin,
            videoLinkHeadersReferer: videoLinkHeadersReferer)
        
        // Save to localVideoUrl
        let tempDirectory = FileManager.default.temporaryDirectory
        let localVideoUrl = tempDirectory.appendingPathComponent("tempVideo_ChefApp_SwiftUI.mp4")
        try localVideoData.write(to: localVideoUrl)
        
        // Extract audio from video with headers
        let localAudioUrl = try await extractAudio(
            from: localVideoUrl
        )
        
        // Ensure unwrap audioData, otherwise throw invalidAudioData
        let localAudioData: Data
//        do {
        localAudioData = try Data(contentsOf: localAudioUrl)
//        } catch {
//            // TODO: Find out if this is a good way to handle this
//            print("Error getting audio data in TikTokTranscriber... \(error)")
//            throw TikTokTranscriberError.invalidAudioData
//        }
        
        // Transcribe audio
        let transcribeSpeechResponse = try await ChefAppNetworkService.transcribeSpeech(
            request: TranscribeSpeechRequest(
                authToken: authToken,
                speechFileName: "audio.m4a",
                speechFile: localAudioData))
        
        // Clean up temp video and audio files
        try FileManager.default.removeItem(at: localVideoUrl)
        try FileManager.default.removeItem(at: localAudioUrl)
        
        // Return transcription
        return transcribeSpeechResponse.body.text
    }
    
//    // Request Speech Recognition Authorization
//    static func requestSpeechAuthorization() async {
//        await withCheckedContinuation { continuation in
//            SFSpeechRecognizer.requestAuthorization { status in
//                switch status {
//                case .authorized:
//                    print("Speech recognition authorized")
//                case .denied, .restricted, .notDetermined:
//                    print("Speech recognition not authorized")
//                @unknown default:
//                    print("Unknown authorization status")
//                }
//                
//                continuation.resume()
//            }
//        }
//    }
    
//    // Function to transcribe video
//    private static func transcribeVideo(
//        videoURL: String,
//        videoLinkHeadersCookie: String,
//        videoLinkHeadersOrigin: String?,
//        videoLinkHeadersReferer: String?
//    ) async throws -> String {
//        guard let videoURL = URL(string: videoURL) else {
//            throw TikTokTranscriberError.invalidVideoURL
//        }
//        
//        // Step 1: Download video data with headers
//        let videoData = try await downloadVideo(
//            from: videoURL,
//            videoLinkHeadersCookie: videoLinkHeadersCookie,
//            videoLinkHeadersOrigin: videoLinkHeadersOrigin,
//            videoLinkHeadersReferer: videoLinkHeadersReferer)
//        
//        // Step 2: Save video to a temporary location
//        let tempDirectory = FileManager.default.temporaryDirectory
//        let tempVideoURL = tempDirectory.appendingPathComponent("tempVideo_ChefApp_SwiftUI.mp4")
//        try videoData.write(to: tempVideoURL)
//        
//        // Step 3: Extract audio from video
//        let audioURL = try await extractAudio(from: tempVideoURL)
//        
//        // Step 4: Perform speech recognition on extracted audio
//        let transcript = try await transcribeAudio(audioURL: audioURL)
//        
//        // Clean up temporary files
//        try FileManager.default.removeItem(at: tempVideoURL)
//        try FileManager.default.removeItem(at: audioURL)
//        
//        // Return transcript
//        return transcript
//    }
    
    // Function to download video data with headers
    private static func downloadVideo(
        from url: URL,
        videoLinkHeadersCookie: String,
        videoLinkHeadersOrigin: String?,
        videoLinkHeadersReferer: String?
    ) async throws -> Data {
        var request = URLRequest(url: url)
        // Add custom headers if needed
        // For example, adding a cookie
        request.setValue(videoLinkHeadersCookie, forHTTPHeaderField: "Cookie")
        if let videoLinkHeadersOrigin {
            request.setValue(videoLinkHeadersOrigin, forHTTPHeaderField: "Origin")
        }
        if let videoLinkHeadersReferer {
            request.setValue(videoLinkHeadersReferer, forHTTPHeaderField: "Referer")
        }
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        // Check response status code
        if let httpResponse = response as? HTTPURLResponse,
           !(200...299).contains(httpResponse.statusCode) {
            throw URLError(.badServerResponse)
        }
        
        return data
    }
    
    // Function to extract audio from video
    private static func extractAudio(
        from localVideoURL: URL
//        videoLinkHeadersCookie: String,
//        videoLinkHeadersOrigin: String?,
//        videoLinkHeadersReferer: String?
    ) async throws -> URL {
        return try await withCheckedThrowingContinuation { continuation in
            // Prepare HTTP headers
            var headers = [String: String]()

//            // Get the cookie from the response
//            headers["Cookie"] = videoLinkHeadersCookie
//            if let origin = videoLinkHeadersOrigin {
//                headers["Origin"] = origin
//            }
//            if let referer = videoLinkHeadersReferer {
//                headers["Referer"] = referer
//            }
            
            // Create AVURLAsset with custom headers
            let asset = AVURLAsset(url: localVideoURL)//, options: ["AVURLAssetHTTPHeaderFieldsKey": headers])
            
            // Export to audio
            guard let exportSession = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetAppleM4A) else {
                continuation.resume(throwing: NSError(domain: "ExportSession", code: -1, userInfo: [NSLocalizedDescriptionKey: "Cannot create export session"]))
                return
            }

            // Create temp audio directory
            let audioURL = FileManager.default.temporaryDirectory.appendingPathComponent("tempAudio.m4a")
            // Remove the file if it already exists
            try? FileManager.default.removeItem(at: audioURL)
            
            // Export audio
            exportSession.outputURL = audioURL
            exportSession.outputFileType = .m4a
            exportSession.exportAsynchronously {
                switch exportSession.status {
                case .completed:
                    continuation.resume(returning: audioURL)
                case .failed, .cancelled:
                    if let error = exportSession.error {
                        continuation.resume(throwing: error)
                    } else {
                        continuation.resume(throwing: NSError(domain: "ExportSession", code: -1, userInfo: [NSLocalizedDescriptionKey: "Unknown export error"]))
                    }
                default:
                    break
                }
            }
        }
    }
    
    // Function to transcribe audio using Speech framework
    private static func transcribeAudio(
        audioURL: URL
    ) async throws -> String {
        return try await withCheckedThrowingContinuation { continuation in
            let recognizer = SFSpeechRecognizer()
            guard let recognizer = recognizer, recognizer.isAvailable else {
                continuation.resume(throwing: NSError(domain: "SpeechRecognizer", code: -1, userInfo: [NSLocalizedDescriptionKey: "Speech recognizer not available"]))
                return
            }
            
            let request = SFSpeechURLRecognitionRequest(url: audioURL)
            recognizer.recognitionTask(with: request) { result, error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else if let result = result, result.isFinal {
                    continuation.resume(returning: result.bestTranscription.formattedString)
                }
            }
        }
    }
    
}
