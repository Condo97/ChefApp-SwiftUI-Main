//
//  ChefAppNetworkService.swift
//  ChefApp-SwiftUI
//
//  Created by Alex Coundouriotis on 11/11/23.
//

import Foundation

class ChefAppNetworkService {
    
    static func addOrRemoveLikeOrDislike(request: AddOrRemoveLikeOrDislikeRequest) async throws {
        let (data, response) = try await NetworkClient.post(
            url: URL(string: "\(Constants.HTTPSConstants.chitChatServer)\(Constants.HTTPSConstants.addOrRemoveLikeOrDislike)")!,
            body: request,
            headers: nil)
    }
    
    static func categorizeIngredients(request: CategorizeIngredientsRequest) async throws -> CategorizeIngredientsResponse {
        let (data, response) = try await NetworkClient.post(
            url: URL(string: "\(Constants.HTTPSConstants.chitChatServer)\(Constants.HTTPSConstants.categorizeIngredients)")!,
            body: request,
            headers: nil)
        
        do {
            let categorizeIngredientsResponse = try JSONDecoder().decode(CategorizeIngredientsResponse.self, from: data)
            
            return categorizeIngredientsResponse
        } catch {
            print("Error decoding categorizeIngredients response..")
            
            // Try to parse error response, and throw NetworkingError with corresponding value
            let errorResponse = try JSONDecoder().decode(ErrorResponse.self, from: data)
            
            print("Error Response from categorizeIngredients response:\n\(errorResponse)")
            
            throw NetworkingError(rawValue: errorResponse.success) ?? NetworkingError.clientUnhandledError
        }
    }
    
    static func createRecipeIdea(request: CreateRecipeIdeaRequest) async throws -> CreateRecipeIdeaResponse {
        let (data, response) = try await NetworkClient.post(
            url: URL(string: "\(Constants.HTTPSConstants.chitChatServer)\(Constants.HTTPSConstants.createRecipeIdea)")!,
            body: request,
            headers: nil)
        
        do {
            let createRecipeIdeaResponse = try JSONDecoder().decode(CreateRecipeIdeaResponse.self, from: data)
            
            return createRecipeIdeaResponse
        } catch {
            print("Error decoding createRecipeIdea response..")
            
            // Try to parse error response, and throw NetworkingError with corresponding value
            let errorResponse = try JSONDecoder().decode(ErrorResponse.self, from: data)
            
            print("Error Response from createRecipeIdea response:\n\(errorResponse)")
            
            throw NetworkingError(rawValue: errorResponse.success) ?? NetworkingError.clientUnhandledError
        }
    }
    
    static func getAllTags(request: AuthRequest) async throws -> GetAllTagsResponse {
        let (data, response) = try await NetworkClient.post(
            url: URL(string: "\(Constants.HTTPSConstants.chitChatServer)\(Constants.HTTPSConstants.getAllTags)")!,
            body: request,
            headers: nil)
        
        do {
            let getAllTagsResponse = try JSONDecoder().decode(GetAllTagsResponse.self, from: data)
            
            return getAllTagsResponse
        } catch {
            print("Error decoding getAllTags response..")
            
            // Try to parse error response, and throw NetworkingError with corresponding value
            let errorResponse = try JSONDecoder().decode(ErrorResponse.self, from: data)
            
            print("Error Response from getAllTags response:\n\(errorResponse)")
            
            throw NetworkingError(rawValue: errorResponse.success) ?? NetworkingError.clientUnhandledError
        }
    }
    
    public static func getAndDuplicateRecipe(request: GetAndDuplicateRecipeRequest) async throws -> GetAndDuplicateRecipeResponse {
        let (data, response) = try await NetworkClient.post(
            url: URL(string: "\(Constants.HTTPSConstants.chitChatServer)\(Constants.HTTPSConstants.getAndDuplicateRecipe)")!,
            body: request,
            headers: nil)
        
        do {
            let getAndDuplicateRecipeResponse = try JSONDecoder().decode(GetAndDuplicateRecipeResponse.self, from: data)
            
            return getAndDuplicateRecipeResponse
        } catch {
            print("Error decoding getAndDuplicateRecipe response..")
            
            // Try to parse error response, and throw NetworkingError with corresponding value
            let errorResponse = try JSONDecoder().decode(ErrorResponse.self, from: data)
            
            print("Error Response from getAndDuplicateRecipe response:\n\(errorResponse)")
            
            throw NetworkingError(rawValue: errorResponse.success) ?? NetworkingError.clientUnhandledError
        }
    }
    
    public static func getCreatePanels() async throws -> GetCreatePanelsResponse {
        let (data, response) = try await NetworkClient.post(
            url: URL(string: "\(Constants.HTTPSConstants.chitChatServer)\(Constants.HTTPSConstants.getCreatePanels)")!,
            body: BlankRequest(),
            headers: nil)
        
        do {
            let createPanelsResponse = try JSONDecoder().decode(GetCreatePanelsResponse.self, from: data)
            
            return createPanelsResponse
        } catch {
            print("Error decoding CreatePanelsResponse in getCreatePanels in BarbackNetworkService... \(error)")
            
            // Try to parse error response, and throw NetworkingError with corresponding value
            let errorResponse = try JSONDecoder().decode(ErrorResponse.self, from: data)
            
            print("Error Response from getAllTags response:\n\(errorResponse)")
            
            throw NetworkingError(rawValue: errorResponse.success) ?? NetworkingError.clientUnhandledError
        }
    }
    
    static func getIAPStuff(completion: @escaping (GetIAPStuffResponse)->Void) {
        do {
            try NetworkClient.post(
                url: URL(string: "\(Constants.HTTPSConstants.chitChatServer)\(Constants.HTTPSConstants.getIAPStuff)")!,
                body: BlankRequest(),
                headers: nil,
                completion: {data, error in
                    if let error = error {
                        print("Error getting IAP stuff")
                        print(error.localizedDescription)
                    } else if let data = data {
                        do {
                            // Try decoding to GetIAPStuffResponse
                            let getIAPStuffResponse = try JSONDecoder().decode(GetIAPStuffResponse.self, from: data)

                            // Call completion block
                            completion(getIAPStuffResponse)
                        } catch {
                            print("Error decoding to GetIAPStuffResponse")
                            print(error.localizedDescription)
                        }
                    }
                }
            )
        } catch {
            print("Error making POST requet in getIAPStuff")
            print(error.localizedDescription)
        }
    }

    static func getImportantConstants() async throws -> GetImportantConstantsResponse {
        let (data, response) = try await NetworkClient.post(
            url: URL(string: "\(Constants.HTTPSConstants.chitChatServer)\(Constants.HTTPSConstants.getImportantConstants)")!,
            body: BlankRequest(),
            headers: nil)
        
        do {
            let getImportantConstantsResponse = try JSONDecoder().decode(GetImportantConstantsResponse.self, from: data)
            
            return getImportantConstantsResponse
        } catch {
            // Catch as StatusResponse
            let statusResponse = try JSONDecoder().decode(StatusResponse.self, from: data)
            
            // Regenerate AuthToken if necessary
            if statusResponse.success == 5 {
                Task {
                    do {
                        try await AuthHelper.regenerate()
                    } catch {
                        print("Error regenerating authToken in HTTPSConnector... \(error)")
                    }
                }
            }
            
            throw error
        }
    }
    
    static func getIsPremium(request: AuthRequest) async throws -> IsPremiumResponse {
        let (data, response) = try await NetworkClient.post(
            url: URL(string: "\(Constants.HTTPSConstants.chitChatServer)\(Constants.HTTPSConstants.getIsPremium)")!,
            body: request,
            headers: nil)

        let isPremiumResponse = try JSONDecoder().decode(IsPremiumResponse.self, from: data)

        return isPremiumResponse
    }
    
    static func getRemaining(request: AuthRequest) async throws -> GetRemainingResponse {
        let (data, response) = try await NetworkClient.post(
            url: URL(string: "\(Constants.HTTPSConstants.chitChatServer)\(Constants.HTTPSConstants.getRemaining)")!,
            body: request,
            headers: nil)

        let getRemainingResponse = try JSONDecoder().decode(GetRemainingResponse.self, from: data)

        return getRemainingResponse
    }

    // TODO: Legacy need to delete
    static func getRemaining(request: AuthRequest, completion: @escaping (GetRemainingResponse)->Void) {
        do {
            try NetworkClient.post(
                url: URL(string: "\(Constants.HTTPSConstants.chitChatServer)\(Constants.HTTPSConstants.getRemaining)")!,
                body: request,
                headers: nil,
                completion: {data, error in
                    if let error = error {
                        print("Error getting remaining")
                        print(error.localizedDescription)
                    } else if let data = data {
                        do {
                            // Try decoding to GetRemainingResponse
                            let getRemainingResponse = try JSONDecoder().decode(GetRemainingResponse.self, from: data)

                            // Call completion block
                            completion(getRemainingResponse)
                        } catch {
                            print("Error decoding to GetRemainingResponse")
                            print(error.localizedDescription)
                        }
                    }
                }
            )
        } catch {
            print("Error making POST request in getRemaining")
            print(error.localizedDescription)
        }
    }
    
    static func logPinterestConversion(request: LogPinterestConversionRequest) async throws -> LogPinterestConversionResponse {
        let (data, response) = try await NetworkClient.post(
            url: URL(string: "\(Constants.HTTPSConstants.chitChatServer)\(Constants.HTTPSConstants.logPinterestConversion)")!,
            body: request,
            headers: nil)
        
        do {
            let logPinterestConversionResponse = try JSONDecoder().decode(LogPinterestConversionResponse.self, from: data)
            
            return logPinterestConversionResponse
        } catch {
            print("Error decoding logPinterestConversionResponse response..")
            
            // Try to parse error response, and throw NetworkingError with corresponding value
            let errorResponse = try JSONDecoder().decode(ErrorResponse.self, from: data)
            
            print("Error Response from logPinterestConversion response:\n\(errorResponse)")
            
            throw NetworkingError(rawValue: errorResponse.success) ?? NetworkingError.clientUnhandledError
        }
    }
    
    static func makeRecipeFromIdea(request: MakeRecipeFromIdeaRequest) async throws -> MakeRecipeFromIdeaResponse {
        let (data, response) = try await NetworkClient.post(
            url: URL(string: "\(Constants.HTTPSConstants.chitChatServer)\(Constants.HTTPSConstants.makeRecipeFromIdea)")!,
            body: request,
            headers: nil)
        
        do {
            let makeRecipeFromIdeaResponse = try JSONDecoder().decode(MakeRecipeFromIdeaResponse.self, from: data)
            
            return makeRecipeFromIdeaResponse
        } catch {
            print("Error decoding makeRecipeFromIdea response..")
            
            // Try to parse error response, and throw NetworkingError with corresponding value
            let errorResponse = try JSONDecoder().decode(ErrorResponse.self, from: data)
            
            print("Error Response from makeRecipeFromIdea response:\n\(errorResponse)")
            
            throw NetworkingError(rawValue: errorResponse.success) ?? NetworkingError.clientUnhandledError
        }
    }
    
    static func parsePantryItems(request: ParsePantryItemsRequest) async throws -> ParsePantryItemsResponse {
        let (data, response) = try await NetworkClient.post(
            url: URL(string: "\(Constants.HTTPSConstants.chitChatServer)\(Constants.HTTPSConstants.parsePantryItems)")!,
            body: request,
            headers: nil)
        
        do {
            return try JSONDecoder().decode(ParsePantryItemsResponse.self, from: data)
        } catch {
            throw NetworkingError(rawValue: try JSONDecoder().decode(ErrorResponse.self, from: data).success) ?? .unknown
        }
    }
    
    static func regenerateRecipeDirectionsAndIdeaRecipeIngredients(request: RegenerateRecipeMeasuredIngredientsAndDirectionsAndIdeaRecipeIngredientsRequest) async throws -> RegenerateRecipeDirectionsAndIdeaRecipeIngredientsResponse {
        let (data, response) = try await NetworkClient.post(
            url: URL(string: "\(Constants.HTTPSConstants.chitChatServer)\(Constants.HTTPSConstants.regenerateRecipeDirectionsAndIdeaRecipeIngredients)")!,
            body: request,
            headers: nil)
        
        do {
            let regenerateRecipeDirectionsAndIdeaRecipeIngredientsResponse = try JSONDecoder().decode(RegenerateRecipeDirectionsAndIdeaRecipeIngredientsResponse.self, from: data)
            
            return regenerateRecipeDirectionsAndIdeaRecipeIngredientsResponse
        } catch {
            let errorResponse = try JSONDecoder().decode(ErrorResponse.self, from: data)
            
            throw NetworkingError(rawValue: errorResponse.success) ?? .unknown
        }
    }
    
    static func registerAPNS(request: APNSRegistrationRequest) async throws -> StatusResponse {
        let (data, response) = try await NetworkClient.post(
            url: URL(string: "\(Constants.HTTPSConstants.chitChatServer)\(Constants.HTTPSConstants.registerAPNS)")!,
            body: request,
            headers: nil)
        
        let statusResponse = try JSONDecoder().decode(StatusResponse.self, from: data)
        
        return statusResponse
    }
    
    static func registerUser() async throws -> RegisterUserResponse {
        let (data, response) = try await NetworkClient.post(
            url: URL(string: "\(Constants.HTTPSConstants.chitChatServer)\(Constants.HTTPSConstants.registerUser)")!,
            body: BlankRequest(),
            headers: nil)

        do {
            let registerUserResponse = try JSONDecoder().decode(RegisterUserResponse.self, from: data)

            return registerUserResponse
        } catch {
            let errorResponse = try JSONDecoder().decode(ErrorResponse.self, from: data)
            
            throw NetworkingError(rawValue: errorResponse.success) ?? .unknown
        }
    }
    
    // TODO: Legacy so need to delete
    static func registerUser(completion: @escaping (RegisterUserResponse)->Void) {
        do {
            try NetworkClient.post(
                url: URL(string: "\(Constants.HTTPSConstants.chitChatServer)\(Constants.HTTPSConstants.registerUser)")!,
                body: BlankRequest(),
                headers: nil,
                completion: {data, error in
                    if let error = error {
                        print("Error registering user")
                        print(error)
                    } else if let data = data {
                        do {
                            // Try decoding to RegisterUserResponse
                            let registerUserResponse = try JSONDecoder().decode(RegisterUserResponse.self, from: data)

                            // Call completion block
                            completion(registerUserResponse)
                        } catch {
                            print("Error decoding to RegisterUserResponse")
                            print(error.localizedDescription)
                        }
                    }
                }
            )
        } catch {
            print("Error making POST request in registerUser")
            print(error.localizedDescription)
        }
    }
    
    static func tagRecipeIdea(request: TagRecipeIdeaRequest) async throws -> TagRecipeIdeaResponse {
        let (data, response) = try await NetworkClient.post(
            url: URL(string: "\(Constants.HTTPSConstants.chitChatServer)\(Constants.HTTPSConstants.tagRecipeIdea)")!,
            body: request,
            headers: nil)
        
        do {
            let tagRecipeIdeaResponse = try JSONDecoder().decode(TagRecipeIdeaResponse.self, from: data)
            
            return tagRecipeIdeaResponse
        } catch {
            print("Error decoding tagRecipeIdea response..")
            
            // Try to parse error response, and throw NetworkingError with corresponding value
            let errorResponse = try JSONDecoder().decode(ErrorResponse.self, from: data)
            
            print("Error Response from tagRecipeIdea response:\n\(errorResponse)")
            
            throw NetworkingError(rawValue: errorResponse.success) ?? NetworkingError.clientUnhandledError
        }
    }
    
    static func tikApiGetVideoInfoRequest(request: TikAPIGetVideoInfoRequest) async throws -> TikAPIGetVideoInfoResponse {
        let (data, response) = try await NetworkClient.post(
            url: URL(string: "\(Constants.HTTPSConstants.chitChatServer)\(Constants.HTTPSConstants.tikApiGetVideoInfo)")!,
            body: request,
            headers: nil)
        
        do {
            let tikApiGetVideoInfoResponse = try JSONDecoder().decode(TikAPIGetVideoInfoResponse.self, from: data)
            
            return tikApiGetVideoInfoResponse
        } catch {
            print("Error decoding tikApiGetVideoInfo response.. \(error)")
            
            // Try to parse error response, and throw NetworkingError with corresponding value
            let errorResponse = try JSONDecoder().decode(ErrorResponse.self, from: data)
            
            print("Error Response from tikApiGetVideoInfo response:\n\(errorResponse)")
            
            throw NetworkingError(rawValue: errorResponse.success) ?? NetworkingError.clientUnhandledError
        }
    }
    
    static func tikTokSearch(request: TikTokSearchRequest) async throws -> TikAPISearchResponse {
        let (data, response) = try await NetworkClient.post(
            url: URL(string: "\(Constants.HTTPSConstants.chitChatServer)\(Constants.HTTPSConstants.tikTokSearch)")!,
            body: request,
            headers: nil)
        
        do {
            let tikTokSearchResponse = try JSONDecoder().decode(TikAPISearchResponse.self, from: data)
            
            return tikTokSearchResponse
        } catch {
            print("Error decoding tikTokSearch response.. \(error)")
            
            // Try to parse error response, and throw NetworkingError with corresponding value
            let errorResponse = try JSONDecoder().decode(ErrorResponse.self, from: data)
            
            print("Error Response from tikTokSearch response:\n\(errorResponse)")
            
            throw NetworkingError(rawValue: errorResponse.success) ?? NetworkingError.clientUnhandledError
        }
    }
    
    static func transcribeSpeech(request: TranscribeSpeechRequest) async throws -> TranscribeSpeechResponse {
        let (data, response) = try await NetworkClient.post(
            url: URL(string: "\(Constants.HTTPSConstants.chitChatServer)\(Constants.HTTPSConstants.transcribeSpeech)")!,
            body: request,
            headers: nil)
        
        do {
            return try JSONDecoder().decode(TranscribeSpeechResponse.self, from: data)
        } catch {
            // Catch as StatusResponse
            let statusResponse = try JSONDecoder().decode(StatusResponse.self, from: data)
            
            // Regenerate AuthToken if necessary
            if statusResponse.success == 5 {
                Task {
                    do {
                        try await AuthHelper.regenerate()
                    } catch {
                        print("Error regenerating authToken in HTTPSConnector... \(error)")
                    }
                }
            }
            
            throw error
        }
    }
    
    static func updateRecipeImageURL(request: UpdateRecipeImageURLRequest) async throws {
        let (data, response) = try await NetworkClient.post(
            url: URL(string: "\(Constants.HTTPSConstants.chitChatServer)\(Constants.HTTPSConstants.updateRecipeImageURL)")!,
            body: request,
            headers: nil)
    }
    
    static func validateAuthToken(request: AuthRequest) async throws -> ValidateAuthTokenResponse {
        let (data, response) = try await NetworkClient.post(
            url: URL(string: "\(Constants.HTTPSConstants.chitChatServer)\(Constants.HTTPSConstants.validateAuthToken)")!,
            body: request,
            headers: nil)
        
        do {
            let validateAuthTokenResponse = try JSONDecoder().decode(ValidateAuthTokenResponse.self, from: data)
            
            return validateAuthTokenResponse
        } catch {
            print("Error decoding validateAuthToken response..")
            
            // Try to parse error response, and throw NetworkingError with corresponding value
            let errorResponse = try JSONDecoder().decode(ErrorResponse.self, from: data)
            
            print("Error Response from validateAuthToken response:\n\(errorResponse)")
            
            throw NetworkingError(rawValue: errorResponse.success) ?? NetworkingError.clientUnhandledError
        }
    }
    
}
