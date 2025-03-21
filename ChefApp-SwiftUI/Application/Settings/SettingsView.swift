//
//  SettingsView.swift
//  Barback
//
//  Created by Alex Coundouriotis on 10/5/23.
//

import SwiftUI

struct SettingsView: View {
    
    @ObservedObject var premiumUpdater: PremiumUpdater // TODO: Should this instead just communicate showUltraView and shouldRestore?
    @Binding var isShowing: Bool
    
    
    @State var isShowingUltraView: Bool = false
    @State var isShowingPrivacyPolicyWebView: Bool = false
    @State var isShowingTermsWebView: Bool = false
    
    var body: some View {
        VStack(spacing: 0.0) {
//            header
            Spacer()
            
            List {
                if !premiumUpdater.isPremium {
                    Section {
                        premium
                    }
                }
                
                Section {
                    share
                    
                    privacyPolicy
                    
                    termsOfService
                    
                    restorePurchases
                }
            }
            .scrollContentBackground(.hidden)
            .background(Colors.background)
        }
        .foregroundStyle(Colors.foregroundText)
        .background(Colors.background)
        .toolbar {
            LogoToolbarItem(foregroundColor: Colors.elementBackground)
        }
        .toolbarBackground(Colors.background, for: .navigationBar)
        .navigationBarTitleDisplayMode(.inline)
        .ultraViewPopover(isPresented: $isShowingUltraView)
    }
    
//    var header: some View {
//        ZStack {
//            HStack {
//                VStack {
//                    Spacer()
//                    Button(action: {
//                        withAnimation {
//                            isShowing = false
//                        }
//                    }) {
//                        Text("Back")
//                            .font(.custom(Constants.FontName.black, size: 20.0))
//                            .foregroundStyle(Colors.elementText)
//                            .padding(.bottom, 8)
//                            .padding(.leading)
//                    }
//                }
//                Spacer()
//            }
//            
//            HStack {
//                Spacer()
//                VStack {
//                    Spacer()
//                    Text("Barback")
//                        .font(.custom(Constants.FontName.appname, size: 34.0))
//                        .foregroundStyle(Colors.elementText)
//                        .padding(4)
//                }
//                Spacer()
//            }
//        }
//        .frame(height: 100)
//        .background(foregroundColor)
//    }
    
    var premium: some View {
        Button(action: {
            HapticHelper.doLightHaptic()
            
            isShowingUltraView = true
        }) {
            HStack {
                Image(systemName: "gift")
                    .font(.custom(Constants.FontName.medium, size: 24.0))
                    .frame(width: 60.0)
                Text("Get 3 Days")
                    .font(.custom(Constants.FontName.body, size: 17.0))
                Text("Free")
                    .font(.custom(Constants.FontName.black, size: 17.0))
                Spacer()
                Text(Image(systemName: "chevron.right"))
                    .font(.custom(Constants.FontName.body, size: 17.0))
            }
            .padding([.top, .bottom], 8)
        }
    }
    
    var share: some View {
        Button(action: {
            HapticHelper.doLightHaptic()
            
            PasteboardHelper.copy(ConstantsUpdater.shareURL)
        }) {
            HStack {
                Image(systemName: "person.3")
                    .font(.custom(Constants.FontName.heavy, size: 20.0))
                    .frame(width: 60.0)
                Text("Share")
                    .font(.custom(Constants.FontName.black, size: 17.0))
                Text("with Friends")
                    .font(.custom(Constants.FontName.body, size: 17.0))
                Spacer()
                Text(Image(systemName: "chevron.right"))
                    .font(.custom(Constants.FontName.body, size: 17.0))
            }
        }
        .padding([.top, .bottom], 8)
    }
    
    var privacyPolicy: some View {
        Button(action: {
            HapticHelper.doLightHaptic()
            
            isShowingPrivacyPolicyWebView = true
        }) {
            HStack {
                Image(systemName: "paperclip")
                    .font(.custom(Constants.FontName.medium, size: 24.0))
                    .frame(width: 60.0)
                Text("Privacy Policy")
                    .font(.custom(Constants.FontName.body, size: 17.0))
                Spacer()
                Text(Image(systemName: "chevron.right"))
                    .font(.custom(Constants.FontName.body, size: 17.0))
            }
        }
        .padding([.top, .bottom], 8)
        .fullScreenCover(isPresented: $isShowingPrivacyPolicyWebView) {
            VStack {
                WebView(url: URL(string: "\(Constants.HTTPSConstants.chitChatServerStaticFiles)\(Constants.HTTPSConstants.privacyPolicy)")!)
                    .chefAppHeader(showsDivider: true, left: {
                        Button(action: {
                            HapticHelper.doLightHaptic()
                            
                            withAnimation {
                                isShowingPrivacyPolicyWebView = false
                            }
                        }) {
                            Text("Back")
                                .font(.custom(Constants.FontName.black, size: 20.0))
                                .foregroundStyle(Colors.elementText)
                                .padding(.bottom, 8)
                                .padding(.leading)
                        }
                    }, right: {
                        
                    })
                    .background(Colors.elementBackground)
                    .ignoresSafeArea()
            }
        }
    }
    
    var termsOfService: some View {
        Button(action: {
            HapticHelper.doLightHaptic()
            
            isShowingTermsWebView = true
        }) {
            HStack {
                Image(systemName: "newspaper")
                    .font(.custom(Constants.FontName.medium, size: 24.0))
                    .frame(width: 60.0)
                Text("Terms of Service")
                    .font(.custom(Constants.FontName.body, size: 17.0))
                Spacer()
                Text(Image(systemName: "chevron.right"))
                    .font(.custom(Constants.FontName.body, size: 17.0))
                
            }
        }
        .padding([.top, .bottom], 8)
        .fullScreenCover(isPresented: $isShowingTermsWebView) {
            VStack {
                WebView(url: URL(string: "\(Constants.HTTPSConstants.chitChatServerStaticFiles)\(Constants.HTTPSConstants.termsAndConditions)")!)
                    .chefAppHeader(showsDivider: true, left: {
                        Button(action: {
                            HapticHelper.doLightHaptic()
                            
                            withAnimation {
                                isShowingTermsWebView = false
                            }
                        }) {
                            Text("Back")
                                .font(.custom(Constants.FontName.black, size: 20.0))
                                .foregroundStyle(Colors.elementText)
                                .padding(.bottom, 8)
                                .padding(.leading)
                        }
                    }, right: {
                        
                    })
                    .background(Colors.elementBackground)
                    .ignoresSafeArea()
            }
        }
        
    }
    
    var restorePurchases: some View {
        Button(action: {
            HapticHelper.doLightHaptic()
            
            isShowingUltraView = true
        }) {
            HStack {
                Image(systemName: "arrow.2.circlepath")
                    .font(.custom(Constants.FontName.medium, size: 24.0))
                    .frame(width: 60.0)
                Text("Restore Purchases")
                    .font(.custom(Constants.FontName.body, size: 17.0))
                Spacer()
                Text(Image(systemName: "chevron.right"))
                    .font(.custom(Constants.FontName.body, size: 17.0))
            }
        }
        .padding([.top, .bottom], 8)
    }
    
}

#Preview {
    NavigationStack {
        SettingsView(
            premiumUpdater: PremiumUpdater(),
            isShowing: .constant(true))
    }
}
