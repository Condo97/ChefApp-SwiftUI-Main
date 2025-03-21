//
//  AdOrReviewCoordinator.swift
//  ChefApp-SwiftUI
//
//  Created by Alex Coundouriotis on 12/6/24.
//

import Foundation
import _StoreKit_SwiftUI

class AdOrReviewCoordinator: ObservableObject {
    
    @Published var isShowingInterstitial: Bool = false
    @Published var requestedReview: Bool = false
    
    private var totalShowCallCount: Int = 0
    
    private let cooldown: Int = 3 // Invoke every 3 times
    private let reviewFrequency: Int = 3 // Show review every 3 times unless review has been received
    
    func showWithCooldown(isPremium: Bool) async {
        // Increment totalShowCallCount, doing it first to make sure it shows after cooldown period
        totalShowCallCount += 1
        
        if totalShowCallCount % cooldown == 0 {
            // Show
            await showImmediately(isPremium: isPremium)
        }
    }
    
    func showImmediately(isPremium: Bool) async {
        // Generate random number to see if it equals reviewFrequency to show a review
        let random = Int.random(in: 1...reviewFrequency)
        
        // Show review if random number is reviewFrequency, otherwise if premium show interstitial
        if random == reviewFrequency {
            await showReviewImmediately()
        } else {
            await showAdImmediately(isPremium: isPremium)
        }
    }
    
    func showAdImmediately(isPremium: Bool) async {
        await MainActor.run {
            if !isPremium {
                isShowingInterstitial = true
            }
        }
    }
    
    func showReviewImmediately() async {
        await MainActor.run {
            requestedReview = true
        }
    }
    
}

