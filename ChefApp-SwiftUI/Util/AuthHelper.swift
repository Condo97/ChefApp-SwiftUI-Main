//
//  AuthHelper.swift
//  ChitChat
//
//  Created by Alex Coundouriotis on 3/30/23.
//

import Foundation

class AuthHelper {
    
    static func get() -> String? {
        return UserDefaults.standard.string(forKey: Constants.UserDefaults.storedAuthTokenKey)
    }
    
    /***
     Ensure - Gets the authToken either from the server or locally
     
     throws
        - If the client cannot get the AuthToken from the server and there is no AuthToken available locally
     */
    static func ensure() async throws -> String {
        // If authToken, verify it with the server and if not valid set storerd to nil so that it will register a new user
        if let authToken = get() {
            // TODO: Should I be creating the requests somewhere else, and what would I call it?
            // Create authRequest
            let authRequest = AuthRequest(
                authToken: authToken
            )
            
            // If not valid, set to nil
            if try await !ChefAppNetworkService.validateAuthToken(request: authRequest).body.isValid {
                UserDefaults.standard.set(nil, forKey: Constants.UserDefaults.storedAuthTokenKey)
            }
        }
        
        // If there is an authTokne, return it, otherise register the user and update the authToken in UserDefaults
        if let authToken = get() {
            return authToken
        } else {
            let registerUserResponse = try await ChefAppNetworkService.registerUser()
            
            let authToken = registerUserResponse.body.authToken
            
            UserDefaults.standard.set(authToken, forKey: Constants.UserDefaults.storedAuthTokenKey)
                
            return authToken
        }
        
    }
    
    /***
     Regenerate - Deletes current authToken and gets a new one from the server
     
     throws
        - If the client cannot get the AuthToken from the server and there is no AuthToken available locally
     */
    @discardableResult
    static func regenerate() async throws -> String {
        UserDefaults.standard.set(nil, forKey: Constants.UserDefaults.storedAuthTokenKey)
        
        let registerUserResponse = try await ChefAppNetworkService.registerUser()
        
        UserDefaults.standard.set(registerUserResponse.body.authToken, forKey: Constants.UserDefaults.storedAuthTokenKey)
        
        return UserDefaults.standard.string(forKey: Constants.UserDefaults.storedAuthTokenKey)!
    }
    
}
