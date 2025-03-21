//
//  CapReachedCard.swift
//  ChefApp-SwiftUI
//
//  Created by Alex Coundouriotis on 6/19/24.
//

import SwiftUI

struct CapReachedCard: View {
    
    @State private var isShowingUltraView: Bool = false
    
    var body: some View {
        ZStack {
            HStack {
                Spacer()
                VStack {
                    Spacer()
                    Text("Cap Reached")
                        .font(.custom(Constants.FontName.black, size: 28.0))
                        .foregroundStyle(Colors.foregroundText)
                        .padding(.bottom, 8)
                    
                    Text("Full recipes use a lot of resources to generate, so free users are limited. Please upgrade to get unlimited recipes & more!")
                        .font(.custom(Constants.FontName.body, size: 17.0))
                        .foregroundStyle(Colors.foregroundText)
                        .multilineTextAlignment(.center)
                        .padding(.bottom, 8)
                    
                    Text("Unlock 3 Days FREE by Upgrading Today...")
                        .font(.custom(Constants.FontName.heavyOblique, size: 14.0))
                        .multilineTextAlignment(.center)
                    
                    Button(action: {
                        HapticHelper.doLightHaptic()
                        
                        isShowingUltraView = true
                    }) {
                        Spacer()
                        VStack {
                            Text("Upgrade Now \(Image(systemName: "chevron.right"))")
                                .font(.custom(Constants.FontName.black, size: 24.0))
                            Text("First 3 Days Free & UNLIMITED!")
                                .font(.custom(Constants.FontName.bodyOblique, size: 14.0))
                        }
                        Spacer()
                    }
                    .foregroundStyle(Colors.elementText)
                    .padding()
                    .background(Colors.elementBackground)
                    .clipShape(RoundedRectangle(cornerRadius: 24.0))
                    Spacer()
                }
                Spacer()
            }
        }
        .padding()
        .background(Colors.foreground)
        .clipShape(RoundedRectangle(cornerRadius: 24.0))
        .ultraViewPopover(isPresented: $isShowingUltraView)
    }
    
}

#Preview {
    CapReachedCard()
}
