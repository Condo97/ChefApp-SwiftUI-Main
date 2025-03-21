//
//  RemainingUpdater.swift
//  Barback
//
//  Created by Alex Coundouriotis on 10/7/23.
//

import Foundation

class RemainingUpdater: ObservableObject {
    
    @Published var remaining: Int? = persistentRemaining
    
    
    private static var persistentRemaining: Int {
        get {
            UserDefaults.standard.integer(forKey: Constants.UserDefaults.storedRecipesRemaining)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Constants.UserDefaults.storedRecipesRemaining)
        }
    }
    
    func set(recipesRemaining: Int) {
        RemainingUpdater.persistentRemaining = recipesRemaining
        
        DispatchQueue.main.async {
            self.remaining = recipesRemaining
        }
    }
    
    func update(authToken: String) async throws {
        // Build authRequest
        let authRequest = AuthRequest(authToken: authToken)
        
        // Do request
        let remainingResponse = try await ChefAppNetworkService.getRemaining(request: authRequest)
        
        // Set persistentRemaining to response remainingDrinks
        set(recipesRemaining: remainingResponse.body.remaining)
    }
    
}
