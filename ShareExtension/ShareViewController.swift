//
//  ShareViewController.swift
//  StudyAIShareExtension
//
//  Created by Alex Coundouriotis on 9/13/24.
//

import CoreServices
import MobileCoreServices
import Social
import UIKit
import UniformTypeIdentifiers

class ShareViewController: UIViewController {
    
    override func viewDidLoad() {
//        handleSharedContent()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        DispatchQueue.main.async {
            self.handleSharedContent()
            self.openURL(URL(string: "chefapp://sharedata")!)
            
//            self.extensionContext?.open(URL(string: "https://apple.com")!, completionHandler: { value in
//                print(value)
//            })
            
            
            // Inform the host that we're done
            self.extensionContext?.completeRequest(returningItems: nil, completionHandler: nil)
        }
    }
    
    func handleSharedContent() {
            // Process the shared items
            if let extensionItem = extensionContext?.inputItems.first as? NSExtensionItem {
                if let attachments = extensionItem.attachments {
                    for provider in attachments {
                        // Handle URLs
                        if provider.hasItemConformingToTypeIdentifier(UTType.url.identifier) {
                            provider.loadItem(forTypeIdentifier: UTType.url.identifier, options: nil) { (item, error) in
                                if let url = item as? URL {
                                    self.saveSharedData(url: url)
                                }
                            }
                            return
                        }
                        // Handle Text
                        else if provider.hasItemConformingToTypeIdentifier(UTType.text.identifier) {
                            provider.loadItem(forTypeIdentifier: UTType.text.identifier, options: nil) { (item, error) in
                                if let text = item as? String {
                                    self.saveSharedData(text: text)
                                }
                            }
                            return
                        }
                        // Handle Images
                        else if provider.hasItemConformingToTypeIdentifier(UTType.image.identifier) {
                            provider.loadItem(forTypeIdentifier: UTType.image.identifier, options: nil) { (item, error) in
                                if let imageURL = item as? URL {
                                    let imageData: Data
                                    do {
                                        imageData = try Data(contentsOf: imageURL)
                                    } catch {
                                        // TODO: Handle Errors
                                        print("Error getting imageData in ShareViewController... \(error)")
                                        return
                                    }
                                    
                                    self.saveSharedData(imageData: imageData)
                                } else if let image = item as? UIImage, let imageData = image.pngData() {
                                    self.saveSharedData(imageData: imageData)
                                }
                            }
                            return
                        }
                        // Handle PDFs
                        else if provider.hasItemConformingToTypeIdentifier(UTType.pdf.identifier) {
                            provider.loadItem(forTypeIdentifier: UTType.pdf.identifier, options: nil) { (item, error) in
                                if let pdfURL = item as? URL {
                                    self.saveSharedData(fileURL: pdfURL)
                                }
                            }
                            return
                        }
                        // Handle Audio/Voice files
                        else if provider.hasItemConformingToTypeIdentifier(UTType.audio.identifier) {
                            provider.loadItem(forTypeIdentifier: UTType.audio.identifier, options: nil) { (item, error) in
                                if let audioURL = item as? URL {
                                    self.saveSharedData(fileURL: audioURL)
                                }
                            }
                            return
                        }
                        // Add more handlers if needed
                    }
                }
            }
        }
    
    @objc
    @discardableResult
    func openURL(_ url: URL) -> Bool {
        var responder: UIResponder? = self
        while responder != nil {
            if let application = responder as? UIApplication {
                application.open(url, options: [:], completionHandler: { completion in
                    print(completion)
                })
                return true
//                return application.perform(#selector(openURL(_:)), with: url) != nil
            }
            responder = responder?.next
        }
        return false
    }

        func saveSharedData(url: URL) {
            let fileSaver = AppGroupSaver(appGroupIdentifier: Constants.Additional.appGroupID)
            let sharedData = SharedData(url: url.absoluteString)
            _ = fileSaver.saveCodable(sharedData, to: "sharedData.json")
        }

        func saveSharedData(text: String) {
            let fileSaver = AppGroupSaver(appGroupIdentifier: Constants.Additional.appGroupID)
            let sharedData = SharedData(text: text)
            _ = fileSaver.saveCodable(sharedData, to: "sharedData.json")
        }

        func saveSharedData(imageData: Data) {
            let fileSaver = AppGroupSaver(appGroupIdentifier: Constants.Additional.appGroupID)
            let imageFileName = "sharedImage.png"
            _ = fileSaver.saveFile(data: imageData, destinationFileName: imageFileName)

            let sharedData = SharedData(imageAppGroupFilepath: imageFileName)
            _ = fileSaver.saveCodable(sharedData, to: "sharedData.json")
        }

        func saveSharedData(fileURL: URL) {
            let fileSaver = AppGroupSaver(appGroupIdentifier: Constants.Additional.appGroupID)
            let fileName = fileURL.lastPathComponent
            _ = fileSaver.saveFile(from: fileURL, destinationFileName: fileName)

            var sharedData = SharedData()
            if fileName.lowercased().hasSuffix(".pdf") {
                sharedData.pdfAppGroupFilepath = fileName
            } else if fileName.lowercased().hasSuffix(".m4a") || fileName.lowercased().hasSuffix(".mp3") || fileName.lowercased().hasSuffix(".wav") {
                sharedData.voiceAppGroupFilepath = fileName
            } else {
                // Handle other file types if needed
            }
            _ = fileSaver.saveCodable(sharedData, to: "sharedData.json")
        }

}


