//
//  RecipeSwipeCardsView.swift
//  ChefApp-SwiftUI
//
//  Created by Alex Coundouriotis on 12/7/24.
//
// https://www.reddit.com/r/SwiftUI/comments/1fux4ai/tinderlike_swipeable_cards_in_swiftui_tutorial/?rdt=48146
// https://medium.com/@jaredcassoutt/creating-tinder-like-swipeable-cards-in-swiftui-193fab1427b8

import SwiftUI

struct RecipeSwipeCardsView: View {
    
    class Model: ObservableObject {
        private var originalCards: [RecipeSwipeCardView.Model]
        @Published var unswipedCards: [RecipeSwipeCardView.Model]
        @Published var swipedCards: [RecipeSwipeCardView.Model]
        
        init(cards: [RecipeSwipeCardView.Model]) {
            self.originalCards = cards
            self.unswipedCards = cards
            self.swipedCards = []
        }
        
        func removeTopCard() {
            if !unswipedCards.isEmpty {
                guard let card = unswipedCards.first else { return }
                unswipedCards.removeFirst()
                swipedCards.append(card)
            }
        }
        
        func updateTopCardSwipeDirection(_ direction: RecipeSwipeCardView.SwipeDirection) {
            if !unswipedCards.isEmpty {
                unswipedCards[0].swipeDirection = direction
            }
        }
        
        func undo() -> RecipeSwipeCardView.Model? {
            if let lastSwipedCard = swipedCards.popLast() {
                unswipedCards.insert(lastSwipedCard, at: 0)
                return lastSwipedCard
            }
            
            return nil
        }
        
        func reset() {
            unswipedCards = originalCards
            swipedCards = []
        }
    }
    
    @ObservedObject var model: Model
    let onTap: (_ card: RecipeSwipeCardView.Model) -> Void
    let onSwipe: (_ card: RecipeSwipeCardView.Model, _ swipeDirection: RecipeSwipeCardView.SwipeDirection) -> Void
    let onSwipeComplete: () -> Void
    let onClose: () -> Void
    
    var body: some View {
//        let _ = Self._printChanges()
        VStack {
            GeometryReader { geometry in
                if model.unswipedCards.isEmpty {
                    emptyCardsView
                        .frame(width: geometry.size.width, height: geometry.size.height)
                } else if model.unswipedCards.isEmpty {
                    swipingCompletionView
                        .frame(width: geometry.size.width, height: geometry.size.height)
                } else {
                    ZStack {
                        Colors.background.ignoresSafeArea()
                        
                        ForEach(model.unswipedCards.reversed()) { card in
                            RecipeSwipableCardView(
                                model: card,
                                size: geometry.size,
                                onTap: {
                                    // Call onTap closure with card
                                    onTap(card)
                                },
                                onSwipe: { swipeDirection in
                                    // Update card swipe direction
                                    card.swipeDirection = swipeDirection
                                    
                                    // Call onSwipe closure with card and swipe direction
                                    onSwipe(card, swipeDirection)
                                },
                                onSwipeComplete: {
                                    // Remove top card TODO: This can be handled better
                                    model.removeTopCard()
                                    
                                    // Call onSwipeComplete closure
                                    onSwipeComplete()
                                })
                        }
                    }
                }
            }
            .padding()
        }
    }
    
    var emptyCardsView: some View {
        VStack {
            Text("No Cards")
                .font(.title)
                .padding(.bottom, 20)
                .foregroundStyle(.gray)
        }
    }
    
    var swipingCompletionView: some View {
        VStack {
            Text("Finished Swiping")
                .font(.title)
                .padding(.bottom, 20)
            
            // TODO: Make this button more customizable and have it call onFinishAction
            Button(action: {
                onClose()
            }) {
                Text("Close")
                    .font(.headline)
                    .frame(width: 200, height: 50)
                    .background(Color.accentColor)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
        }
    }
}

#Preview {
    
    let cards = (try! CDClient.mainManagedObjectContext.fetch(Recipe.fetchRequest())).map({ RecipeSwipeCardView.Model(
        recipe: $0,
        imageURL: AppGroupLoader(appGroupIdentifier: Constants.Additional.appGroupID).fileURL(for: $0.imageAppGroupLocation!),
        name: $0.name,
        summary: $0.summary
    ) })
    
    return RecipeSwipeCardsView(
        model: RecipeSwipeCardsView.Model(
            cards: cards),
        onTap: { card in
            
        },
        onSwipe: { card, swipeDirection in
            
        },
        onSwipeComplete: {
            
        },
        onClose: {
            
        })
        .environment(\.managedObjectContext, CDClient.mainManagedObjectContext)
    
}
