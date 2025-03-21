//
//  RecipeSwipableCardView.swift
//  ChefApp-SwiftUI
//
//  Created by Alex Coundouriotis on 12/12/24.
//

import SwiftUI

struct RecipeSwipableCardView: View {
    
    let model: RecipeSwipeCardView.Model
    let size: CGSize
//    let isTopCard: Bool
//    let isSecondCard: Bool
    let onTap: () -> Void
    let onSwipe: (_ swipeDirection: RecipeSwipeCardView.SwipeDirection) -> Void
    let onSwipeComplete: () -> Void
    
    private let swipeThreshold: CGFloat = 100.0
    private let rotationFactor: Double = 35.0
    
    @State private var dragState = CGSize.zero
    @State private var cardRotation: Double = 0
    
    var body: some View {
        RecipeSwipeCardView(
            model: model,
            size: size)
//            isTopCard: isTopCard,
//            isSecondCard: isSecondCard)
        .shadow(color: getShadowColor(), radius: 10, x: 0, y: 3)
        .offset(x: dragState.width)
        .rotationEffect(.degrees(Double(dragState.width) / rotationFactor))
        .onTapGesture {
            onTap()
        }
        .gesture(
            DragGesture()
                .onChanged { gesture in
                    self.dragState = gesture.translation
                    self.cardRotation = Double(gesture.translation.width) / rotationFactor
                }
                .onEnded { _ in
                    if abs(self.dragState.width) > swipeThreshold {
                        let swipeDirection: RecipeSwipeCardView.SwipeDirection = self.dragState.width > 0 ? .right : .left
//                        model.updateTopCardSwipeDirection(swipeDirection) Moved to parent
                        
                        // Call onSwipe
                        onSwipe(swipeDirection)
                        
                        withAnimation(.easeOut(duration: 0.5)) {
                            self.dragState.width = self.dragState.width > 0 ? 1000 : -1000
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
//                            self.model.removeTopCard() Moved to parent
                            self.dragState = .zero
                            onSwipeComplete()
                        }
                    } else {
                        withAnimation(.spring()) {
                            self.dragState = .zero
                            self.cardRotation = 0
                        }
                    }
                }
        )
        .animation(.easeInOut, value: dragState)
    }
    
    private func getShadowColor() -> Color {
        if dragState.width > 0 {
            return Color.green.opacity(0.5)
        } else if dragState.width < 0 {
            return Color.red.opacity(0.5)
        } else {
            return Color.gray.opacity(0.2)
        }
    }
    
}

//#Preview {
//    
//    RecipeSwipableCardView()
//
//}
