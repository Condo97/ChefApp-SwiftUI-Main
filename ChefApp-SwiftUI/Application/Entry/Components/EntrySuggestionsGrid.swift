//
//  EntrySuggestionsGrid.swift
//  ChefApp-SwiftUI
//
//  Created by Alex Coundouriotis on 3/17/25.
//

import SwiftUI

struct EntrySuggestionsGrid: View {
    
    @Binding var selectedSuggestions: [String]
    
    
    var body: some View {
        VStack {
            ScrollView(.horizontal) {
                VStack {
                    HStack {
                        ForEach(SuggestionsModel.topSuggestions, id: \.self) { suggestion in
                            Button(action: {
                                HapticHelper.doLightHaptic()
                                
                                // Remove suggestion from selectedSuggestions if it's in there otherwise add it
                                if selectedSuggestions.contains(suggestion) {
                                    withAnimation(.bouncy(duration: 0.5)) {
                                        selectedSuggestions.removeAll(where: {$0 == suggestion})
                                    }
                                } else {
                                    withAnimation(.bouncy(duration: 0.5)) {
                                        selectedSuggestions.append(suggestion)
                                    }
                                }
                            }) {
                                Text(suggestion)
                                    .font(.custom(Constants.FontName.medium, size: 14.0))
                            }
                            .padding(8)
                            .foregroundStyle(Colors.foregroundText)
                            .background(selectedSuggestions.contains(suggestion) ? Color(uiColor: .systemGreen).opacity(0.4) : .clear)
                            .background(Colors.foreground)
                            .clipShape(RoundedRectangle(cornerRadius: 14.0))
                        }
                        
                        Spacer()
                    }
                    .padding([.leading, .trailing])
                    
                    HStack {
                        ForEach(SuggestionsModel.bottomSuggestions, id: \.self) { suggestion in
                            Button(action: {
                                HapticHelper.doLightHaptic()
                                
                                // Remove suggestion from selectedSuggestions if it's in there otherwise add it
                                if selectedSuggestions.contains(suggestion) {
                                    withAnimation(.bouncy(duration: 0.5)) {
                                        selectedSuggestions.removeAll(where: {$0 == suggestion})
                                    }
                                } else {
                                    withAnimation(.bouncy(duration: 0.5)) {
                                        selectedSuggestions.append(suggestion)
                                    }
                                }
                            }) {
                                Text(suggestion)
                                    .font(.custom(Constants.FontName.medium, size: 14.0))
                            }
                            .padding(8)
                            .foregroundStyle(Colors.foregroundText)
                            .background(selectedSuggestions.contains(suggestion) ? Color(uiColor: .systemGreen).opacity(0.4) : .clear)
                            .background(Colors.foreground)
                            .clipShape(RoundedRectangle(cornerRadius: 14.0))
                        }
                        Spacer()
                    }
                    .padding([.leading, .trailing])
                }
            }
            .scrollIndicators(.never)
        }
    }
    
}
