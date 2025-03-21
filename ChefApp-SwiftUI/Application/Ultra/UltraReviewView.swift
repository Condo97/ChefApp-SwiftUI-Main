//
//  UltraReviewView.swift
//  Barback
//
//  Created by Alex Coundouriotis on 10/7/23.
//

import SwiftUI

struct UltraReviewView: View {
    
    @State var stars: Int
    @State var text: String
    
    var body: some View {
        ZStack {
            VStack {
                HStack {
                    Spacer()
                    Image("LeftFeather")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 32.0)
                    VStack {
                        HStack {
                            Image(systemName: "star.fill")
                                .font(.custom(Constants.FontName.body, size: 14.0))
                            Image(systemName: "star.fill")
                                .font(.custom(Constants.FontName.body, size: 14.0))
                            Image(systemName: "star.fill")
                                .font(.custom(Constants.FontName.body, size: 14.0))
                            Image(systemName: "star.fill")
                                .font(.custom(Constants.FontName.body, size: 14.0))
                            Image(systemName: "star.fill")
                                .font(.custom(Constants.FontName.body, size: 14.0))
                        }
                        Text("\"\(text)\"")
                            .multilineTextAlignment(.center)
                            .font(.custom(Constants.FontName.body, size: 12.0))
                            .minimumScaleFactor(0.5)
                            .padding(.top, 8)
                    }
                    Image("RightFeather")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 32.0)
                    Spacer()
                }
            }
        }
    }
    
}

#Preview {
    UltraReviewView(
        stars: 5,
        text: "The easiest way to craft custom cocktails.")
        .padding(40)
}
