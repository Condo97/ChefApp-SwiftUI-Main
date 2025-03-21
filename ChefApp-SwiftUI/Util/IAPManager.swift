//
//  IAPManager.swift
//  ChitChat
//
//  Created by Alex Coundouriotis on 4/16/23.
//

//import FirebaseAnalytics
import Foundation
import StoreKit
import UIKit

class IAPManager: NSObject, SKPaymentTransactionObserver {
    
    static var storeKitTaskHandle: Task<Void, Error>?
    
    enum PurchaseError: Error {
        case pending
        case failed
        case cancelled
    }
    
    static func fetchProducts(productIDs: [String]) async throws -> [Product] {
        let storeProducts = try await Product.products(for: Set(productIDs))
        
        return storeProducts
    }
    
    static func purchase(_ product: Product) async throws -> Transaction {
        let result = try await product.purchase()
        
        switch result {
        case .pending:
            throw PurchaseError.pending
        case .success(let verification):
            switch verification {
            case .verified(let transaction):
//                // Log to Google Analytics
//                Analytics.logTransaction(transaction)
                
                // Finish transaction
                await transaction.finish()
                
                // Return transaction
                return transaction
            case .unverified:
                throw PurchaseError.failed
            }
        case .userCancelled:
            throw PurchaseError.cancelled
        @unknown default:
            assertionFailure("Unexpected result purchasing product in IAPManager")
            throw PurchaseError.failed
        }
        
    }
    
//    static func refreshReceipt() async {
//        class ReceiptRefreshRequestWrapper: NSObject, SKRequestDelegate {
//
//            private var completion: ((Bool)->Void)?
//
//            func doReceiptRefresh(completion: @escaping (Bool)->Void) {
//                self.completion = completion
//
//                let request = SKReceiptRefreshRequest()
//                request.delegate = self
//                request.start()
//            }
//
//            func requestDidFinish(_ request: SKRequest) {
//                completion?(true)
//            }
//
//            func request(_ request: SKRequest, didFailWithError error: Error) {
//                print("Error refreshing receipt: \(error.localizedDescription)")
//                completion?(false)
//            }
//        }
//
//        await withCheckedContinuation { continuation in
//            ReceiptRefreshRequestWrapper().doReceiptRefresh(completion: { success in
//                print("First")
//                continuation.resume()
//            })
//        }
//
////        ReceiptRefreshRequestWrapper().doReceiptRefresh()
//
//        print("Second")
//    }
    
    static func startStoreKitListener() {
        storeKitTaskHandle = listenForStoreKitUpdates()
    }
    
    static func listenForStoreKitUpdates() -> Task<Void, Error> {
        Task.detached {
            for await result in Transaction.updates {
                switch result {
                case .verified(let Transaction):
                    await Transaction.finish()
                    
                    print("Transaction verified in IAPManager listenForStoreKitUpdates")
                    
                    //TODO: Update isPremium, or do a server check with the new receipt
                    return
                case .unverified:
                    print("Transaction unverified in IAPManager listenForStoreKitUpdates")
                }
            }
        }
    }
    
    static func getVerifiedTransactions() async -> [Transaction] {
        var transactionList: [Transaction] = []
        
        for await result in Transaction.currentEntitlements {
            do {
                switch result {
                case .verified(let Transaction):
                    await Transaction.finish()
                    
                    print("Transaction verified in IAPManager getVerifiedTransactions")
                    
                    transactionList.append(Transaction)
                case .unverified:
                    print("Tranaction unverified in IAPManager getVerifiedTransactions")
                }
            }
        }
        
        return transactionList
    }
    
    
    static func refreshReceipt() {
        // Refresh the reciept for Tenjin and stuff
        let refreshReceiptRequest = SKReceiptRefreshRequest(receiptProperties: nil)
//        refreshReceiptRequest.delegate = self // Set delegate to self to receive callbacks
        refreshReceiptRequest.start() // This starts the receipt refresh process
    }
    
//    func requestDidFinish(_ request: SKRequest) {
//        print("Hi")
//    }
    
    
    override init() {
        super.init()
        
        SKPaymentQueue.default().add(self)
    }
    
    deinit {
        SKPaymentQueue.default().remove(self)
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        print("Hi")
    }
    
}

