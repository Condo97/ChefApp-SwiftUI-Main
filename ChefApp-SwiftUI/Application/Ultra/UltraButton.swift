//
//  UltraButton.swift
//  WriteSmith-SwiftUI
//
//  Created by Alex Coundouriotis on 10/27/23.
//

import SwiftUI

struct UltraButton: View {
    
    let color: Color
    @State var sparkleDiameter: CGFloat = 28.0
    @State var fontSize: CGFloat = 20.0
    @State var cornerRadius: CGFloat = 24.0
    @State var horizontalSpacing: CGFloat = 4.0
    @State var innerPadding: CGFloat = 8.0
//    @State var lineWidth: CGFloat = 2.0
    
    @EnvironmentObject var premiumUpdater: PremiumUpdater
    @EnvironmentObject var productUpdater: ProductUpdater
    @EnvironmentObject var remainingUpdater: RemainingUpdater
    
    
    @Environment(\.colorScheme) private var colorScheme: ColorScheme
    
    @State private var isShowingUltraView: Bool = false
    
    private var sparkleImageName: String {
        Constants.ImageName.sparkleWhiteGif//colorScheme == .dark ? Constants.ImageName.sparkleDarkGif : Constants.ImageName.sparkleLightGif
    }
    
    var body: some View {
        ZStack {
            Button(action: {
                // Do light haptic
                HapticHelper.doLightHaptic()
                
                // Show Ultra View
                isShowingUltraView = true
            }) {
                HStack(spacing: horizontalSpacing) {
                    SwiftyGif(name: sparkleImageName)
                        .frame(width: sparkleDiameter, height: sparkleDiameter)
                        .colorMultiply(color)
                    
                    Text("\(remainingUpdater.remaining ?? 0)")
                        .font(.custom(Constants.FontName.black, size: fontSize))
                }
//                .foregroundStyle(Colors.navigationItemColor)
                .foregroundStyle(color)
                .padding(innerPadding)
                .padding([.leading, .trailing], innerPadding / 2)
                .background(
                    ZStack {
//                        RoundedRectangle(cornerRadius: cornerRadius)
//                            .fill(Colors.elementTextColor)
                        RoundedRectangle(cornerRadius: cornerRadius)
//                            .stroke(Colors.navigationItemColor, lineWidth: 2.0)
                            .stroke(color, lineWidth: 2.0)
                    }
                )
            }
        }
        .ultraViewPopover(isPresented: $isShowingUltraView)
    }
    
}

#Preview {
    UltraButton(color: Colors.elementBackground)
        .background(.yellow)
        .environmentObject(RemainingUpdater())
        .environmentObject(PremiumUpdater())
        .environmentObject(ProductUpdater())
}
