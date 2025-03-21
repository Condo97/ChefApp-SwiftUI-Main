//
//  SharedDataReceiver.swift
//  ChefApp-SwiftUI
//
//  Created by Alex Coundouriotis on 12/20/24.
//

import Foundation

class SharedDataReceiver: ObservableObject {
    
    @Published var sharedData: SharedData?
    
    func checkForAndGetSharedData(triesLeft: Int = 5) {
        guard triesLeft > 0 else {
            return
        }
        
        let fileLoader = AppGroupLoader(appGroupIdentifier: Constants.Additional.appGroupID)

        if let sharedData = fileLoader.loadCodable(SharedData.self, from: "sharedData.json") {
            Task {
//                await processSharedData(sharedData)
                DispatchQueue.main.async {
                    self.sharedData = sharedData
                }
                fileLoader.deleteFile(named: "sharedData.json")
            }
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: {
                self.checkForAndGetSharedData(triesLeft: triesLeft - 1)
            })
        }
    }
    
    
}
