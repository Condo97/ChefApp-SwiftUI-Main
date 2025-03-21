//
//  ClearFullScreenCover+View.swift
//  WriteSmith-SwiftUI
//
//  Created by Alex Coundouriotis on 11/16/23.
//
// https://stackoverflow.com/questions/64301041/swiftui-translucent-background-for-fullscreencover

import Foundation
import SwiftUI

struct ClearFullScreenCoverView: UIViewRepresentable {
    
//    private let blurBackground = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
    @State var blurEffectStyle: UIBlurEffect.Style // = .dark
    @State var fadeDelay: CGFloat = 0.1
    @State var fadeDuration: CGFloat = 0.4
    
    func makeUIView(context: Context) -> UIView {
        let view = UIVisualEffectView(effect: UIBlurEffect(style: blurEffectStyle))//UIView()
//        let blurBackground = UIVisualEffectView(effect: UIBlurEffect(style: .light))
//        blurBackground.frame = view.bounds
        view.alpha = 0.0
        
        DispatchQueue.main.async {
            view.superview?.superview?.backgroundColor = .clear
            
            UIView.animate(withDuration: fadeDuration, delay: fadeDelay, animations: {
                view.alpha = 1.0
            })
        }
        
//        view.addSubview(blurBackground)
        
        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        
    }
}

extension View {
    
    func clearFullScreenCover<Content: View>(isPresented: Binding<Bool>, blurStyle: UIBlurEffect.Style = .dark, fadeDelay: CGFloat = 0.1, fadeDuration: CGFloat = 0.4, onDismiss: (()->Void)? = nil, backgroundTapDismisses: Bool = true, @ViewBuilder content: @escaping ()->Content) -> some View {
        self
            .fullScreenCover(isPresented: isPresented, onDismiss: onDismiss, content: {
                ZStack {
                    Color.clear
                    
                    content()
                        .transition(.opacity)
                }
                .background(
                    ClearFullScreenCoverView(
                        blurEffectStyle: blurStyle,
                        fadeDelay: fadeDelay,
                        fadeDuration: fadeDuration)
                    .ignoresSafeArea()
                    .onTapGesture {
                        if backgroundTapDismisses {
                            DispatchQueue.main.async {
                                isPresented.wrappedValue = false
                            }
                        }
                    }
                )
            })
    }
    
    func clearFullScreenCover<Content: View, Item: Identifiable>(item: Binding<Item?>, blurStyle: UIBlurEffect.Style = .dark, fadeDelay: CGFloat = 0.1, fadeDuration: CGFloat = 0.4, onDismiss: (()->Void)? = nil, backgroundTapDismisses: Bool = true, @ViewBuilder content: @escaping (Item)->Content) -> some View {
        self
            .fullScreenCover(item: item) { itemUnwrapped in
                ZStack {
                    Color.clear
                    
                    content(itemUnwrapped)
                        .transition(.opacity)
                }
                .background(
                    ClearFullScreenCoverView(
                        blurEffectStyle: blurStyle,
                        fadeDelay: fadeDelay,
                        fadeDuration: fadeDuration)
                    .ignoresSafeArea()
                    .onTapGesture {
                        if backgroundTapDismisses {
                            DispatchQueue.main.async {
                                item.wrappedValue = nil
                            }
                        }
                    }
                )
            }
    }
    
}
