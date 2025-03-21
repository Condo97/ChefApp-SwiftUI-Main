//
//  ProductUpdater.swift
//  Barback
//
//  Created by Alex Coundouriotis on 10/7/23.
//

import Foundation
import StoreKit
import SwiftUI

class ProductUpdater: ObservableObject {
    
    @Published var shouldRetryLoadingOnError: Bool = false
    @Published var subscriptionActive: Bool = false
    
    @Published var weeklyProduct: Product?
    @Published var monthlyProduct: Product?
    
    
    init() {
        Task {
            await refresh()
        }
    }
    
    func refresh() async {
        let weeklyProductID = ConstantsUpdater.weeklyProductID
        let monthlyProductID = ConstantsUpdater.monthlyProductID
        
        do {
            let products = try await IAPManager.fetchProducts(productIDs: [
                weeklyProductID,
                monthlyProductID
            ])
            
            await MainActor.run {
                self.weeklyProduct = products.first(where: {$0.id == weeklyProductID})
                self.monthlyProduct = products.first(where: {$0.id == monthlyProductID})
            }
        } catch {
            // TODO: Handle errors
            print("Error fetching products in UltraViewModel... \(error)")
        }
    }
    
}
