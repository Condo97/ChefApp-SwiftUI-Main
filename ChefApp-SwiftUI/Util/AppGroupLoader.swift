//
//  AppGroupLoader.swift
//  WriteSmith-SwiftUI
//
//  Created by Alex Coundouriotis on 9/13/24.
//

import Foundation

class AppGroupLoader {
    
    private let appGroupIdentifier: String
    private let fileManager: FileManager

    init(appGroupIdentifier: String) {
        self.appGroupIdentifier = appGroupIdentifier
        self.fileManager = FileManager.default
    }

    // Loads a Codable object
    func loadCodable<T: Codable>(_ type: T.Type, from fileName: String) -> T? {
        do {
            if let data = loadData(from: fileName) {
                let object = try JSONDecoder().decode(type, from: data)
                return object
            } else {
                return nil
            }
        } catch {
            print("Error decoding Codable object: \(error)")
            return nil
        }
    }

    // Loads Data from a file
    func loadData(from fileName: String) -> Data? {
        guard let containerURL = fileManager.containerURL(forSecurityApplicationGroupIdentifier: appGroupIdentifier) else {
            print("Error: Could not find container URL for app group.")
            return nil
        }
        let fileURL = containerURL.appendingPathComponent(fileName)

        do {
            let data = try Data(contentsOf: fileURL)
            return data
        } catch {
            print("Error loading file: \(error)")
            return nil
        }
    }

    // Returns the file URL for a given file name
    func fileURL(for fileName: String) -> URL? {
        guard let containerURL = fileManager.containerURL(forSecurityApplicationGroupIdentifier: appGroupIdentifier) else {
            print("Error: Could not find container URL for app group.")
            return nil
        }
        let fileURL = containerURL.appendingPathComponent(fileName)
        if fileManager.fileExists(atPath: fileURL.path) {
            return fileURL
        } else {
            print("Error: File does not exist at \(fileURL.path)")
            return nil
        }
    }

    // Deletes a file
    func deleteFile(named fileName: String) {
        guard let containerURL = fileManager.containerURL(forSecurityApplicationGroupIdentifier: appGroupIdentifier) else {
            return
        }
        let fileURL = containerURL.appendingPathComponent(fileName)
        if fileManager.fileExists(atPath: fileURL.path) {
            do {
                try fileManager.removeItem(at: fileURL)
            } catch {
                print("Error deleting file: \(error)")
            }
        }
    }
    
}
