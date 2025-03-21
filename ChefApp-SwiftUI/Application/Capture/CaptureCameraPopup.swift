//
//  CaptureCameraPopup.swift
//  ChefApp-SwiftUI
//
//  Created by Alex Coundouriotis on 3/18/25.
//

import SwiftUI

struct CaptureCameraPopup: View {
    
    let onAttach: (_ image: UIImage?, _ cropFrame: CGRect?, _ unmodifiedImage: UIImage?) -> Void
    let onDismiss: () -> Void
    
    var body: some View {
        ZStack {
            CaptureCameraViewControllerRepresentable(
                reset: .constant(false),
                onAttach: onAttach)
            
            VStack {
                HStack {
                    Spacer()
                    Button(action: onDismiss) {
                        ZStack {
                            Image(systemName: "xmark")
                                .resizable()
                                .frame(width: 30.0, height: 30.0)
                                .foregroundStyle(Colors.elementText)
                            
                            Image(systemName: "xmark")
                                .resizable()
                                .frame(width: 28.0, height: 28.0)
                                .foregroundStyle(Colors.elementBackground)
                        }
                        .padding(.top)
                        .padding()
                        .padding()
                    }
                }
                Spacer()
            }
        }
        .ignoresSafeArea()
    }
    
}


extension View {
    
    func captureCameraPopup(isPresented: Binding<Bool>, onAttach: @escaping (_ image: UIImage?, _ cropFrame: CGRect?, _ unmodifiedImage: UIImage?) -> Void) -> some View {
        self
            .fullScreenCover(isPresented: isPresented) {
                CaptureCameraPopup(
                    onAttach: onAttach,
                    onDismiss: {
                        withAnimation {
                            isPresented.wrappedValue = false
                        }
                    })
            }
    }

}
