//
//  IntroView.swift
//  WriteSmith-SwiftUI
//
//  Created by Alex Coundouriotis on 11/1/23.
//

import SwiftUI

struct IntroView<Content: View>: View {
    
    @State var image: Image
    @Binding var isShowingButtonLoading: Bool
    @ViewBuilder var destination: ()->Content
    
    
    @State private var isShowingNext: Bool = false
    
    var body: some View {
        VStack {
            Spacer(minLength: 40)
            
            image
                .resizable()
                .aspectRatio(contentMode: .fit)
            
            Button(action: {
                // Do light haptic
                HapticHelper.doLightHaptic()
                
                // Show next view
                isShowingNext = true
            }) {
                ZStack {
                    Text("Next...")
                        .font(.custom(Constants.FontName.heavy, size: 24.0))
                    
                    HStack {
                        Spacer()
                        if isShowingButtonLoading {
                            ProgressView()
                                .tint(Colors.elementBackground)
                        } else {
                            Text(Image(systemName: "chevron.right"))
                        }
                    }
                }
            }
            .padding()
            .foregroundStyle(Colors.elementText)
//            .foregroundStyle(Colors.elementBackgroundColor)
            .background(Colors.elementBackground)
//            .background(Colors.foreground)
            .clipShape(RoundedRectangle(cornerRadius: Constants.UI.cornerRadius))
            .bounceable(disabled: isShowingButtonLoading)
            .opacity(isShowingButtonLoading ? 0.4 : 1.0)
            .disabled(isShowingButtonLoading)
            .padding()
        }
        .background(Colors.background)
        .toolbar(.hidden, for: .navigationBar)
        .navigationDestination(isPresented: $isShowingNext, destination: destination)
    }
    
}

#Preview {
    NavigationStack {
        IntroView(
            image: Image(uiImage: UIImage(named: IntroPresenterView.lightModeImage1Name)!),
            isShowingButtonLoading: .constant(false),
            destination: {
            Text("You've got to the destination!")
                .toolbar(.hidden, for: .navigationBar)
        })
    }
}
