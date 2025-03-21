//
//  FileSaver.swift
//  WriteSmith-SwiftUI
//
//  Created by Alex Coundouriotis on 9/13/24.
//

import Foundation

class AppGroupSaver {
    
    private let appGroupIdentifier: String
    private let fileManager: FileManager

    init(appGroupIdentifier: String) {
        self.appGroupIdentifier = appGroupIdentifier
        self.fileManager = FileManager.default
    }

    // Saves a Codable object
    func saveCodable<T: Codable>(_ codable: T, to fileName: String) -> Bool {
        do {
            let data = try JSONEncoder().encode(codable)
            return saveData(data, to: fileName)
        } catch {
            print("Error encoding Codable object: \(error)")
            return false
        }
    }

    // Saves Data to a file
    func saveData(_ data: Data, to fileName: String) -> Bool {
        guard let containerURL = fileManager.containerURL(forSecurityApplicationGroupIdentifier: appGroupIdentifier) else {
            print("Error: Could not find container URL for app group.")
            return false
        }
        let fileURL = containerURL.appendingPathComponent(fileName)
        
        do {
            try data.write(to: fileURL)
            return true
        } catch {
            print("Error saving file: \(error)")
            return false
        }
    }

    // Saves a file from a source URL
    func saveFile(from sourceURL: URL, destinationFileName: String) -> Bool {
        guard let containerURL = fileManager.containerURL(forSecurityApplicationGroupIdentifier: appGroupIdentifier) else {
            print("Error: Could not find container URL for app group.")
            return false
        }
        let destinationURL = containerURL.appendingPathComponent(destinationFileName)
        
        do {
            if fileManager.fileExists(atPath: destinationURL.path) {
                try fileManager.removeItem(at: destinationURL)
            }
            try fileManager.copyItem(at: sourceURL, to: destinationURL)
            return true
        } catch {
            print("Error saving file: \(error)")
            return false
        }
    }

    // Saves Data as a file
    func saveFile(data: Data, destinationFileName: String) -> Bool {
        guard let containerURL = fileManager.containerURL(forSecurityApplicationGroupIdentifier: appGroupIdentifier) else {
            print("Error: Could not find container URL for app group.")
            return false
        }
        let destinationURL = containerURL.appendingPathComponent(destinationFileName)
        
        do {
            try data.write(to: destinationURL)
            return true
        } catch {
            print("Error saving file: \(error)")
            return false
        }
    }
    
}
