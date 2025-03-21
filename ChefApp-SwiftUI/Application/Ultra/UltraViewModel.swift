////
////  UltraViewModel.swift
////  Barback
////
////  Created by Alex Coundouriotis on 10/7/23.
////
//
//import Foundation
//import StoreKit
//import SwiftUI
//
//class UltraViewModel: ObservableObject {
//    
//    @Published var isLoading: Bool = false
//    @Published var showLoadingErrorAlert: Bool = false
//    @Published var shouldRetryLoadingOnError: Bool = false
//    @Published var subscriptionActive: Bool = false
//    
//    @EnvironmentObject private var premiumUpdater: PremiumUpdater
//    
//    
//    func purchase(subscriptionPeriod: SubscriptionPeriod) async {
//        guard let authToken = AuthHelper.get() else {
//            // TODO: Handle errors
//            showLoadingErrorAlert = true
//            print("Cound not unwrap authToken in purchase in UltraViewModel!")
//            return
//        }
//        
//        defer {
//            DispatchQueue.main.async {
//                self.isLoading = false
//            }
//        }
//        
//        DispatchQueue.main.async {
//            self.isLoading = true
//        }
//        
//        do {
//            guard let json = try await IAPHTTPSClient.getIAPStuffFromServer(authToken: authToken) else {
//                // TODO: Handle errors
//                DispatchQueue.main.async {
//                    self.showLoadingErrorAlert = true
//                }
//                
//                print("Could not unwrap json from getting IAP stuff from server with IAPHTTPSClient in purchase in UltraViewModel!")
//                return
//            }
//            
//            try await handleGetIAPStuffFromServerResponse(json, subscriptionPeriod: subscriptionPeriod)
//        } catch {
//            // TODO: Handle errors
//            DispatchQueue.main.async {
//                self.showLoadingErrorAlert = true
//            }
//            
//            print("Error getting IAP stuff from server with IAPHTTPSClient in purchase in UltraViewModel... \(error)")
//        }
//    }
//    
//    private func handleGetIAPStuffFromServerResponse(_ json: [String: Any], subscriptionPeriod: SubscriptionPeriod) async throws {
//        guard let success = json["Success"] as? Int else { showGeneralIAPErrorAndUnhide(); return }
//
//        if success == 1 {
//            guard let body = json["Body"] as? [String: Any] else { showGeneralIAPErrorAndUnhide(); return }
//            guard let sharedSecret = body["sharedSecret"] as? String else { showGeneralIAPErrorAndUnhide(); return }
//            guard let productIDs = body["productIDs"] as? [String] else { showGeneralIAPErrorAndUnhide(); return }
//            
//            if productIDs.count > 0 {
//                // Get products from server
//                let products = try await IAPManager.fetchProducts(productIDs: productIDs)
//                
//                guard var productToPurchase: Product = products.first(where: {IAPManager.getSubscriptionPeriod(product: $0) == subscriptionPeriod}) else {
//                    showGeneralRetryableIAPErrorAndUnhide()
//                    return
//                }
//                
//                guard let authToken = try? await AuthHelper.ensure() else {
//                    // If the authToken is nil, show an error alert that the app can't connect to the server and return
//                    showGeneralIAPErrorAndUnhide()
//                    
//                    return
//                }
//                
//                // Purchase the product!
//                let transaction = try await IAPManager.purchase(productToPurchase)
//                
//                // Register the transaction ID with the server
//                try await premiumUpdater.registerTransaction(authToken: authToken, transactionID: transaction.id)
//            }
//        }
//    }
//    
//    private func showGeneralRetryableIAPErrorAndUnhide() {
//        // TODO: Handle errors better
//        shouldRetryLoadingOnError = true
//        showGeneralIAPErrorAndUnhide()
//    }
//    
//    private func showGeneralIAPErrorAndUnhide() {
//        // TODO: Handle errors better
//        DispatchQueue.main.async {
//            self.showLoadingErrorAlert = true
//        }
//    }
//    
//}
