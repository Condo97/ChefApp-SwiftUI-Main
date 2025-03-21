//
//  ImagePickerView.swift
//  ChefApp-SwiftUI
//
//  Created by Alex Coundouriotis on 11/26/24.
//

import SwiftUI

struct ImagePickerView: View {
    
    // TODO: Ability to add image from camera roll
    
    let query: String
    let onClose: () -> Void
    let onSelectImageURL: (URL) -> Void
    
    @State private var imageURLs: [URL] = [] // TODO: Cache images? Should this even be done? What if the next pages are not all of the images and for some reason they go back to the previous ones?
    
    @State private var searchOffset: Int = 0
    
    var body: some View {
        VStack {
            Text("Select Image")
                .font(.custom(Constants.FontName.heavy, size: 20.0))
            
            VStack {
                HStack {
                    imageOrProgressView(forImageAtIndex: 0)
                    imageOrProgressView(forImageAtIndex: 1)
                }
                HStack {
                    imageOrProgressView(forImageAtIndex: 2)
                    imageOrProgressView(forImageAtIndex: 3)
                }
            }
            
            HStack {
                Button(action: {
                    imageURLs = []
                    searchOffset -= 1
                    Task {
                        await fetchNextFourImages()
                    }
                }) {
                    HStack {
                        Image(systemName: "chevron.left")
                        Text("Back")
                    }
                    .font(.custom(Constants.FontName.heavy, size: 17.0))
                    .foregroundStyle(Colors.elementText)
                    .padding(.vertical, 8)
                    .padding(.horizontal)
                    .background(Colors.elementBackground)
                    .clipShape(RoundedRectangle(cornerRadius: 14.0))
                }
                .disabled(searchOffset == 0)
                .opacity(searchOffset == 0 ? 0.2 : 1.0)
                
                VStack {
                    Text("Page")
                        .font(.custom(Constants.FontName.body, size: 12.0))
                    Text("\(searchOffset + 1)")
                        .font(.custom(Constants.FontName.heavy, size: 14.0))
                }
                .padding(.horizontal)
                
                Button(action: {
                    imageURLs = []
                    searchOffset += 1
                    Task {
                        await fetchNextFourImages()
                    }
                }) {
                    HStack {
                        Text("Next")
                        Image(systemName: "chevron.right")
                    }
                    .font(.custom(Constants.FontName.heavy, size: 17.0))
                    .foregroundStyle(Colors.elementText)
                    .padding(.vertical, 8)
                    .padding(.horizontal)
                    .background(Colors.elementBackground)
                    .clipShape(RoundedRectangle(cornerRadius: 14.0))
                }
            }
        }
        .overlay(alignment: .topTrailing) {
            Button(action: { onClose() }) {
                Image(systemName: "xmark")
                    .font(.custom(Constants.FontName.heavy, size: 20.0))
                    .foregroundStyle(Colors.elementBackground)
            }
        }
        .padding()
        .background(Colors.background)
        .clipShape(RoundedRectangle(cornerRadius: 14.0))
        .task {
            await fetchNextFourImages()
        }
    }
    
    func fetchNextFourImages() async {
        do {
            let (imageURLs, totalCountMaybe) = try await BingSearchClient.getImages(
                query: query,
                count: 4,
                offset: searchOffset * 4)
            
//            var images: [UIImage] = []
//            for imageURL in imageURLs {
//                let urlRequest = URLRequest(url: imageURL)
//                
//                do {
//                    // Do request
//                    let (data, response) = try await URLSession.shared.data(for: urlRequest)
//                    
//                    // Try to parse data into image and if successful, add to image array
//                    if let image = UIImage(data: data) {
//                        images.append(image)
//                    }
//                } catch {
//                    print("Error getting response when getting images from Bing search response in ImagePickerView: \(error)")
//                }
//            }
            
            self.imageURLs = imageURLs
        } catch {
            // TODO: Handle Errors
            print("Error getting Bing images in ImagePickerView... \(error)")
        }
    }
    
    func imageOrProgressView(forImageAtIndex index: Int) -> some View {
        ZStack {
            if let imageURL = imageURLs[safe: index] {
                Button(action: { onSelectImageURL(imageURL) }) {
                    AsyncImage(url: imageURL) { phase in
                        switch phase {
                        case .empty:
                            ProgressView()
                        case .success(let image):
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        case .failure(let error):
                            // TODO: Implement better error view for AsyncImage
                            ZStack {
                                Color.elementText
                                Image(systemName: "photo")
                                    .foregroundStyle(Colors.elementBackground)
                            }
                        @unknown default:
                            // TODO: Implement better unknown default view for AsyncImage
                            ZStack {
                                Color.elementText
                                Image(systemName: "photo")
                                    .foregroundStyle(Colors.elementBackground)
                            }
                        }
                    }
                }
            } else {
                ProgressView()
            }
        }
        .frame(width: 150.0, height: 150.0)
        .background(Colors.foreground)
        .clipShape(RoundedRectangle(cornerRadius: 14.0))
    }
    
}

#Preview {
    
    @StateObject var constantsUpdater = ConstantsUpdater()
    
    ImagePickerView(
        query: "Pizza and pasta",
        onClose: {
            
        },
        onSelectImageURL: { imageURL in
            
        }
    )
    .environmentObject(constantsUpdater)
    .task {
        try! await constantsUpdater.update()
    }
    
}
