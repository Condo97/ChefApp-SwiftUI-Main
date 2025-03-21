//
//  RecipeImagePickerView.swift
//  ChefApp-SwiftUI
//
//  Created by Alex Coundouriotis on 11/26/24.
//

import SwiftUI

struct RecipeImagePickerView: View {
    
    let recipe: Recipe
    let onClose: () -> Void
    
    @Environment(\.managedObjectContext) private var viewContext
    
    var body: some View {
        ImagePickerView(
            query: recipe.name ?? "",
            onClose: onClose,
            onSelectImageURL: { imageURL in
                Task {
                    // Get and update image
                    let urlRequest = URLRequest(url: imageURL)
                    let image: UIImage
                    
                    do {
                        // Do request
                        let (data, response) = try await URLSession.shared.data(for: urlRequest)
                        
                        // Try to parse data into image and if successful, add to image array
                        if let unwrappedImage = UIImage(data: data) {
                            image = unwrappedImage
                        } else {
                            // TODO: [Error Handling] Handle Errors
                            print("Could not unwrap selected image in RecipeImagePickerView!")
                            return
                        }
                    } catch {
                        // TODO: [Error Handling] Handle Errors
                        print("Error getting response when getting images from Bing search response in ImagePickerView: \(error)")
                        return
                    }
                    
                    // Ensure authToken
                    let authToken: String
                    do {
                        authToken = try await AuthHelper.ensure()
                    } catch {
                        // TODO: [Error Handling] Handle Errors
                        print("Error ensuring authToken in RecipeImagePickerView... \(error)")
                        return
                    }
                    
                    // Save and upload to server
                    do {
                        try await ChefAppNetworkPersistenceManager.shared.saveAndUploadRecipeImageURLToServer(
                            recipeObjectID: recipe.objectID,
                            image: image,
                            imageExternalURL: imageURL,
                            authToken: authToken,
                            in: viewContext)
                    } catch {
                        // TODO: [Error Handling] Handle Errors
                        print("Error saving and uploading recipe image URL to server in RecipeImagePickerView... \(error)")
                    }
                }
                onClose()
            })
    }
    
}

extension View {
    
    func recipeImagePickerPopup(isPresented: Binding<Bool>, recipe: Recipe) -> some View {
        self
            .clearFullScreenCover(isPresented: isPresented) {
                RecipeImagePickerView(
                    recipe: recipe,
                    onClose: {
                        isPresented.wrappedValue = false
                    })
            }
    }
    
    func recipeImagePickerPopup(recipe: Binding<Recipe?>) -> some View {
        var isPresented: Binding<Bool> {
            Binding(
                get: {
                    recipe.wrappedValue != nil
                },
                set: { value in
                    if !value {
                        recipe.wrappedValue = nil
                    }
                })
        }
        
        return self
            .clearFullScreenCover(isPresented: isPresented) {
                if let recipeWrappedValue = recipe.wrappedValue {
                    RecipeImagePickerView(
                        recipe: recipeWrappedValue,
                        onClose: {
                            isPresented.wrappedValue = false
                        })
                }
            }
    }
    
}

//#Preview {
//    
//    RecipeImagePickerView()
//    
//}
