//
//  UltraView.swift
//  Barback
//
//  Created by Alex Coundouriotis on 10/4/23.
//

import AdSupport
import AppsFlyerLib
import SwiftUI
import StoreKit

struct UltraView: View {
    
//    @ObservedObject var ultraViewModel: UltraViewModel
    @Binding var isShowing: Bool
//    @State var ultraReviewModels: [UltraReviewModel] = UltraReviewModelRepository.models.shuffled()
    
    
    private enum ValidSubscriptions {
        // The subscription id represented as an enum
        case weekly
        case monthly
    }
    
    
    private let showCloseButtonDelay = 2
    private let initialReviewSwitchDelay = 2
    private let reviewSwitchDelay = 3
    private let minReviewGeometryHeight: CGFloat = 100.0
    
    @EnvironmentObject private var premiumUpdater: PremiumUpdater
    @EnvironmentObject private var productUpdater: ProductUpdater
    
    @State private var closeButtonShowing: Bool = false
    @State private var selectedSubscription: ValidSubscriptions = .weekly
    @State private var selectedReviewIndex: Int = 0
    
    @State private var shouldAnimateReviews: Bool = true
    
    @State private var alertShowingDEBUGErrorPurchasing: Bool = false
    @State private var alertShowingErrorRestoringPurchases: Bool = false
    @State private var alertShowingErrorLoading: Bool = false
    
    @State private var isLoadingPurchase: Bool = false
    
    @State private var isShowingPrivacyPolicyWebView: Bool = false
    @State private var isShowingTermsWebView: Bool = false
    
    @State private var isInitialReview: Bool = true
    @State private var justInteractedWithReviews: Bool = false
    
    @State private var errorPurchasing: Error?
    
    
    private let currencyNumberFormatter: NumberFormatter = {
        let currencyNumberFormatter = NumberFormatter()
        currencyNumberFormatter.numberStyle = .decimal
        currencyNumberFormatter.maximumFractionDigits = 2
        currencyNumberFormatter.minimumFractionDigits = 2
        return currencyNumberFormatter
    }()
    
    
    init(isShowing: Binding<Bool>) {
        self._isShowing = isShowing
    }
    
    
    var body: some View {
        ZStack {
            VStack {
                // Header Container
                HStack {
                    VStack(spacing: 0.0) {
                        Color.clear
                            .background(
                                ZStack {
                                    Image(Constants.ImageName.ultraTitle)
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                }
                            )
                            .frame(maxWidth: .infinity, minHeight: 40)
                        
                        VStack {
                            Text("Your AI Chef")
                                .font(.custom(Constants.FontName.black, fixedSize: 42.0))
                                .padding(.top, 8)
                                .onLongPressGesture {
                                    // Show debug error on long press if there is an error stored from when purchasing
                                    if errorPurchasing != nil {
                                        alertShowingDEBUGErrorPurchasing = true
                                    }
                                }
                            
                            Text("Custom recipes from your ingredients.")
                                .font(.custom(Constants.FontName.body, fixedSize: 18.0))
                        }
                        .frame(maxWidth: .infinity)
                        .background(Colors.background)
                    }
                    .foregroundStyle(Colors.foregroundText)
                }
                
                // Features
                Spacer()
                features
                Spacer()
                
                // Buttons Container
                VStack {
                    HStack {
                        Text("Directly Supports the Developer")
                            .font(.custom(Constants.FontName.bodyOblique, size: 12.0))
                            .foregroundStyle(Colors.foregroundText)
                        Text("- Cancel Anytime")
                            .font(.custom(Constants.FontName.blackOblique, size: 12.0))
                            .foregroundStyle(Colors.foregroundText)
                    }
                    .padding(.top, -4)
                    
                    purchaseButtons
                    
                    iapRequiredButtons
                }
                .padding()
            }
            .ignoresSafeArea()
            
            VStack {
                HStack {
                    Button(action: {
                        HapticHelper.doLightHaptic()
                        
                        withAnimation {
                            isShowing = false
                        }
                    }) {
                        Spacer()
                        ZStack {
                            Text(Image(systemName: "xmark"))
                                .font(.custom(Constants.FontName.body, size: closeButtonShowing ? 24.0 : 17.0))
                                .foregroundStyle(Colors.background)
                                .scaleEffect(1.1)
                                .padding(.trailing)
                            
                            Text(Image(systemName: "xmark"))
                                .font(.custom(Constants.FontName.body, size: closeButtonShowing ? 24.0 : 17.0))
                                .foregroundStyle(Colors.foreground)
                                .padding(.trailing)
                        }
                    }
                    .opacity(closeButtonShowing ? 1.0 : 0.2)
                }
                
                Spacer()
            }
        }
        .background(Color("TertiaryBackgroundColor"))
        .task{ await showCloseButtonAfterDelay() }
//        .task { await animateReviews() }
        .alert("Error restoring purchases...", isPresented: $alertShowingErrorRestoringPurchases, actions: {
            Button("Close", role: .cancel, action: {
                
            })
        }) {
            Text("You can try tapping on the subsciption you previously purchased. Apple will prevent a double charge.")
        }
        .alert("DEBUG Error Purchasing", isPresented: $alertShowingDEBUGErrorPurchasing, actions: {
            Button("Close", role: .cancel) {
                
            }
            
            Button("Copy Error") {
                PasteboardHelper.copy(errorPurchasing?.localizedDescription ?? "No Error")
            }
        }) {
            Text(errorPurchasing?.localizedDescription ?? "No Error")
        }
        .alert("Error Loading", isPresented: $alertShowingErrorLoading) {
            Button("Close", action: {
                
            })
        } message: {
            Text("There was an error loading your purchase. Please check your network connection and try again.")
        }
    }
    
    var features: some View {
        VStack(alignment: .leading, spacing: 4.0) {
            HStack(alignment: .top) {
                Text(Image(systemName: "checkmark.square.fill"))
                    .font(.custom(Constants.FontName.body, fixedSize: 24.0))
                    .padding(.top, -4)
                    .padding(.trailing, 8)
                
                Text("Unlimited")
                    .font(.custom(Constants.FontName.black, fixedSize: 20.0))
                Text("Recipes")
                    .font(.custom(Constants.FontName.body, fixedSize: 20.0))
            }
            HStack(alignment: .top) {
                Text(Image(systemName: "checkmark.square.fill"))
                    .font(.custom(Constants.FontName.body, fixedSize: 24.0))
                    .padding(.top, -4)
                    .padding(.trailing, 8)
                
                Text("Five-Star")
                    .font(.custom(Constants.FontName.black, fixedSize: 20.0))
                Text("AI Chef")
                    .font(.custom(Constants.FontName.body, fixedSize: 20.0))
            }
            HStack(alignment: .top) {
                Text(Image(systemName: "checkmark.square.fill"))
                    .font(.custom(Constants.FontName.body, fixedSize: 24.0))
                    .padding(.top, -4)
                    .padding(.trailing, 8)
                
                Text("Remove")
                    .font(.custom(Constants.FontName.black, fixedSize: 20.0))
                Text("Ads")
                    .font(.custom(Constants.FontName.body, fixedSize: 20.0))
            }
            HStack(alignment: .top) {
                Text(Image(systemName: "checkmark.square.fill"))
                    .font(.custom(Constants.FontName.body, fixedSize: 24.0))
                    .padding(.top, -4)
                    .padding(.trailing, 8)
                
                VStack(alignment: .leading) {
                    HStack {
                        Text("Unlock")
                            .font(.custom(Constants.FontName.body, fixedSize: 20.0))
                        Text("20+")
                            .font(.custom(Constants.FontName.black, fixedSize: 20.0))
                    }
                    Text("Creative Features!")
                        .font(.custom(Constants.FontName.black, fixedSize: 20.0))
                }
            }
        }
        .foregroundStyle(Colors.foregroundText)
        .minimumScaleFactor(0.8)
        .padding(20)
//        .background(Colors.elementBackground)
//        .clipShape(RoundedRectangle(cornerRadius: 28.0))
//        .padding()
    }
    
    var iapRequiredButtons: some View {
        HStack {
            Button(action: {
                HapticHelper.doLightHaptic()
                
                isShowingPrivacyPolicyWebView = true
            }) {
                Text("Privacy")
                    .font(.custom(Constants.FontName.body, size: 11.0))
                    .foregroundStyle(Colors.foregroundText)
            }
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
                                    .foregroundStyle(Colors.foregroundText)
                                    .padding(.bottom, 8)
                                    .padding(.leading)
                            }
                        }, right: {
                            
                        })
                        .background(Colors.elementBackground)
                        .ignoresSafeArea()
                }
            }
            
            Button(action: {
                HapticHelper.doLightHaptic()
                
                isShowingTermsWebView = true
            }) {
                Text("Terms")
                    .font(.custom(Constants.FontName.body, size: 11.0))
                    .foregroundStyle(Colors.foregroundText)
            }
            .fullScreenCover(isPresented: $isShowingTermsWebView) {
                VStack {
                    WebView(url: URL(string: "\(Constants.HTTPSConstants.chitChatServerStaticFiles)\(Constants.HTTPSConstants.termsAndConditions)")!)
                        .chefAppHeader(showsDivider: true, left: {
                            Button(action: {
                                withAnimation {
                                    isShowingTermsWebView = false
                                }
                            }) {
                                Text("Back")
                                    .font(.custom(Constants.FontName.black, size: 20.0))
                                    .foregroundStyle(Colors.foregroundText)
                                    .padding(.bottom, 8)
                                    .padding(.leading)
                            }
                        }, right: {
                            
                        })
                        .background(Colors.elementBackground)
                        .ignoresSafeArea()
                }
            }
            
            Spacer()
            
            Button(action: {
                HapticHelper.doLightHaptic()
                
                Task {
                    do {
                        // TODO: How is this processed and how does it actually communicate with the server? Does it at all? Should it call update transaction on the server?
                        try await AppStore.sync()
                        
                        HapticHelper.doSuccessHaptic()
                    } catch {
                        // TODO: Handle Errors
                        print("Error syncing with AppStore in UltraView... \(error)")
                    }
                }
            }) {
                Text("Restore")
                    .font(.custom(Constants.FontName.body, size: 11.0))
                    .foregroundStyle(Colors.foregroundText)
            }
        }
        .padding([.leading, .trailing])
    }
    
    var purchaseButtons: some View {
        VStack(spacing: 8.0) {
//            if let weeklyProduct = productUpdater.weeklyProduct {
//                if let introductaryOffer = weeklyProduct.subscription?.introductoryOffer {
//                    ZStack {
//                        HStack {
//                            Toggle(isOn: freeTrialSelected) {
//                                        let introductaryText = introductaryOffer.price == 0.0 ? "Enable Free Trial" : "Enable Special Offer"
//
//                                        Text(introductaryText)
//                                    .font(.custom(Constants.FontName.medium, size: 17.0))
//
//                            }
//                            .onTapGesture {
//                                HapticHelper.doMediumHaptic()
//                            }
//                            .tint(Colors.elementBackgroundColor)
//                            .foregroundStyle(Colors.elementBackgroundColor)
//                        }
//                    }
//                    .padding(8)
//                    .padding([.leading, .trailing], 8)
//                    .background(
//                        ZStack {
//                            RoundedRectangle(cornerRadius: 14.0)
//                                .fill(Colors.userChatTextColor)
//                        }
//                    )
//                }
//            }
            
            Button(action: {
                // Do light haptic
                HapticHelper.doLightHaptic()
                
                // Set selected subscription to weekly
                selectedSubscription = .weekly
            }) {
                ZStack {
                    if let weeklyProduct = productUpdater.weeklyProduct {
                        let productPriceString = currencyNumberFormatter.string(from: weeklyProduct.price as NSNumber) ?? weeklyProduct.displayPrice
                        
                        HStack {
                            if let introductaryOffer = weeklyProduct.subscription?.introductoryOffer {
                                let offerPriceString = introductaryOffer.price == 0.99 ? "99¢" : currencyNumberFormatter.string(from: introductaryOffer.price as NSNumber) ?? introductaryOffer.displayPrice
                                
                                if introductaryOffer.paymentMode == .freeTrial || introductaryOffer.price == 0.0 {
                                    // Free Trial
                                    let durationString = "\(introductaryOffer.period.value)"
                                    let unitString = switch introductaryOffer.period.unit {
                                    case .day: "Day"
                                    case .week: "Week"
                                    case .month: "Month"
                                    case .year: "Year"
                                    @unknown default: ""
                                    }
                                    
                                    Text("\(durationString) \(unitString) Free Trial")
                                        .font(.custom(Constants.FontName.black, size: 17.0))
                                    +
                                    Text(" - then \(productPriceString) / week")
                                        .font(.custom(Constants.FontName.body, size: 15.0))
                                } else {
                                    // Discount
                                    VStack(alignment: .leading, spacing: 0.0) {
                                        Text("Special Offer - \(offerPriceString) / week")
                                            .font(.custom(Constants.FontName.black, size: 17.0))
                                        let durationString = introductaryOffer.periodCount.word
                                        
                                        Text("for \(durationString) weeks, then \(productPriceString) / week")
                                            .font(.custom(Constants.FontName.bodyOblique, size: 16.0))
                                            .minimumScaleFactor(0.69)
                                            .lineLimit(1)
                                    }
                                }
                                
                            } else {
                                Text("\(productPriceString) / week")
                                    .font(.custom(Constants.FontName.black, size: 17.0))
                            }
                            
                            
                            
                            Spacer()
                            
                            Text(Image(systemName: selectedSubscription == .weekly ? "checkmark.circle.fill" : "circle"))
                                .font(.custom(Constants.FontName.body, size: 28.0))
                                .foregroundStyle(Colors.foregroundText)
                                .padding([.top, .bottom], -6)
                        }
                    } else {
                        HStack {
                            Spacer()
                            Text("Blank")
                                .opacity(0.0)
                            Spacer()
                        }
                    }
                }
            }
            .padding(12)
            .foregroundStyle(Colors.foregroundText)
            .background(
                ZStack {
                    let cornerRadius = 14.0
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .fill(Colors.foreground)
//                    RoundedRectangle(cornerRadius: cornerRadius)
//                        .stroke(Colors.foreground, lineWidth: selectedSubscription == .weekly ? 0.5 : 0.5)
                }
            )
            .opacity(isLoadingPurchase ? 0.4 : 1.0)
            .disabled(isLoadingPurchase)
//            .bounceable(disabled: isLoadingPurchase)
            
            Button(action: {
                // Do light haptic
                HapticHelper.doLightHaptic()
                
                // Set selected subscription to monthly
                selectedSubscription = .monthly
            }) {
                ZStack {
                    if let monthlyProduct = productUpdater.monthlyProduct {
                        let productPriceString = currencyNumberFormatter.string(from: monthlyProduct.price as NSNumber) ?? monthlyProduct.displayPrice
                        
                        HStack {
                            VStack(alignment: .leading, spacing: 0.0) {
                                Text("Monthly - \(productPriceString) / month")
                                    .font(.custom(Constants.FontName.body, size: 17.0))
                                Text("That's 30% Off Weekly!")
                                    .font(.custom(Constants.FontName.black, size: 12.0))
                            }
                            
                            Spacer()
                            
                            Text(Image(systemName: selectedSubscription == .monthly ? "checkmark.circle.fill" : "circle"))
                                .font(.custom(Constants.FontName.body, size: 28.0))
                                .foregroundStyle(Colors.foregroundText)
                                .padding([.top, .bottom], -6)
                        }
                    }
                }
            }
            .padding(12)
            .foregroundStyle(Colors.foregroundText)
            .background(
                ZStack {
                    let cornerRadius = 14.0
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .fill(Colors.foreground)
//                    RoundedRectangle(cornerRadius: cornerRadius)
//                        .stroke(Colors.foreground, lineWidth: selectedSubscription == .monthly ? 0.5 : 0.5)
                }
            )
            .opacity(isLoadingPurchase ? 0.4 : 1.0)
            .disabled(isLoadingPurchase)
//            .bounceable(disabled: isLoadingPurchase)
            
            Button(action: {
                // Do medium haptic
                HapticHelper.doMediumHaptic()
                
                // Purchase
                purchase()
                
//                // Print to server console
//                Task {
//                    guard let authToken = AuthHelper.get() else {
//                        print("Could not unwrap authToken in UltraView!")
//                        return
//                    }
//
//                    let printToConsoleRequst = PrintToConsoleRequest(
//                        authToken: authToken,
//                        message: "Tapped purchase button!")
//
//                    do {
//                        try await ChitChatHTTPSConnector.printToConsole(request: printToConsoleRequst)
//                    } catch {
//                        print("Error sending print to console request in UltraView... \(error)")
//                    }
//                }
            }) {
                ZStack {
                    Text("Next")
                        .font(.custom(Constants.FontName.heavy, size: 20.0))
                    
                    HStack {
                        Spacer()
                        
                        if isLoadingPurchase {
                            ProgressView()
                                .tint(Colors.elementText)
                        } else {
                            Text(Image(systemName: "chevron.right"))
                        }
                    }
                }
            }
            .padding(18)
            .foregroundStyle(Colors.elementText)
            .background(Colors.elementBackground)
            .clipShape(RoundedRectangle(cornerRadius: 14.0))
            .opacity(isLoadingPurchase ? 0.4 : 1.0)
            .disabled(isLoadingPurchase)
            .bounceable(disabled: isLoadingPurchase)
        }
    }
    
//    var reviews: some View {
//        HStack {
//            GeometryReader { geometry in
//                if geometry.size.height > minReviewGeometryHeight {
//                    TabView(selection: $selectedReviewIndex) {
//                        ForEach(0..<ultraReviewModels.count, id: \.self) { i in
//                            let ultraReviewModel = ultraReviewModels[i]
//                            VStack {
//                                UltraReviewView(
//                                    stars: ultraReviewModel.starCount,
//                                    text: ultraReviewModel.text)
//                                .padding()
//                                //                        .frame(maxWidth: geometry.size.width)
//                                .background(Material.regular)
//                                .clipShape(RoundedRectangle(cornerRadius: 28.0))
//                                .frame(width: geometry.size.width / 1.2)
//                                .padding(.bottom, 8)
//                            }
//                            .id(ultraReviewModel)
//                        }
//                    }
//                    //                .indexViewStyle(.page(backgroundDisplayMode: .interactive))
//                    .tabViewStyle(.page(indexDisplayMode: .never))
//                    .onAppear {
//                        UIPageControl.appearance().currentPageIndicatorTintColor = UIColor(Colors.foregroundText.opacity(0.8))
//                        UIPageControl.appearance().pageIndicatorTintColor = UIColor(Colors.foregroundText.opacity(0.2))
//                    }
//                    .gesture(DragGesture()
//                        .onChanged({ value in
//                            // Set justInteractedWithReviews to true on drag
//                            justInteractedWithReviews = true
//                        }))
//                }
//            }
//        }
//    }
    
    func showCloseButtonAfterDelay() async {
        do {
            try await Task.sleep(nanoseconds: UInt64(1_000_000_000 * showCloseButtonDelay))
        } catch {
            // TODO: Handle errors
            print("Error sleeping to show the close button in UltraView... \(error)")
        }
        
        withAnimation {
            closeButtonShowing = true
        }
    }
    
//    func animateReviews() async {
//        while shouldAnimateReviews {
//            do {
//                // Sleep for the correct period of time
//                try await Task.sleep(nanoseconds: UInt64(1_000_000_000 * (isInitialReview ? initialReviewSwitchDelay : reviewSwitchDelay)))
//
//                // Ensure justInteractedWithReviews is false, otherwise set to false and continue to not animate for another loop and delay after user interacted with reviews
//                guard !justInteractedWithReviews else {
//                    justInteractedWithReviews = false
//                    continue
//                }
//
//                // Increment selectedReviewIndex, or set to 0 if the next index would be out of range for ultraReviewModels
//                if selectedReviewIndex + 1 >= ultraReviewModels.count {
//                    DispatchQueue.main.async {
//                        withAnimation {
//                            self.selectedReviewIndex = 0
//                        }
//                    }
//                } else {
//                    DispatchQueue.main.async {
//                        withAnimation {
//                            self.selectedReviewIndex += 1
//                        }
//                    }
//                }
//
//                // Set isInitialReview to false since it will be set to true when the view is loaded
//                isInitialReview = false
//            } catch {
//                // TODO: Handle errors
//                print("Error sleeping to switch the review in UltraView... \(error)")
//                shouldAnimateReviews = false
//            }
//        }
//    }
    
    func purchase() {
//        // Unwrap tappedPeriod
//        guard let selectedSubscription = selectedSubscription else {
//            // TODO: Handle errors
//            print("Could not unwrap tappedPeriod in purchase in UltraView!")
//            return
//        }
        // Get product to purchase
        let product = switch selectedSubscription {
        case .weekly:
            productUpdater.weeklyProduct
        case .monthly:
            productUpdater.monthlyProduct
        }
        
        // Unwrap product
        guard let product = product else {
            // TODO: Handle errors
            print("Could not unwrap product in purchase in UltraView!")
            
            return
        }
        
        // Set isLoadingPurchase to true
        isLoadingPurchase = true
        
        Task {
            defer {
                isLoadingPurchase = false
            }
            
            // Unwrap authToken
            guard let authToken = try? await AuthHelper.ensure() else {
                // If the authToken is nil, show an error alert that the app can't connect to the server and return
                alertShowingErrorLoading = true
                return
            }
            
            // Purchase
            let transaction: StoreKit.Transaction
            do {
                transaction = try await IAPManager.purchase(product)
            } catch {
                // TODO: Handle errors
                print("Error purchasing product in UltraView... \(error)")
                errorPurchasing = error
                return
            }
            
            // If isPremium, log purchase with AppsFlyer
            AppsFlyerLib.shared().logEvent(AFEventPurchase, withValues: [
                AFEventParamContentId: "12345",
                AFEventParamContentType: "ultra_dollar",
                AFEventParamRevenue: 1.0,
                AFEventParamCurrency: "USD"
            ])
            
            // Log Conversion to Pinterest through server if it has not been logged
#if DEBUG
            UserDefaults.standard.set(false, forKey: Constants.UserDefaults.pinterestConversionLoggedOnce)
#endif
            if !UserDefaults.standard.bool(forKey: Constants.UserDefaults.pinterestConversionLoggedOnce) {
                Task {
                    // Get idfa
                    let idfa = ASIdentifierManager.shared().advertisingIdentifier.uuidString
                    
                    // Get authToken
                    let authToken: String
                    do {
                        authToken = try await AuthHelper.ensure()
                    } catch {
                        // TODO: Handle errors
                        print("Error ensuring authToken in UltraView... \(error)")
                        return
                    }
                    
                    let logPinterestConversionRequest = LogPinterestConversionRequest(
                        authToken: authToken,
                        idfa: idfa,
                        eventName: Constants.Additional.pinterestCheckoutEventName,
                        eventID: Constants.Additional.pinterestCheckoutEventID,
                        test: false)
                    
                    do {
                        let logPinterestConversionResponse = try await ChefAppNetworkService.logPinterestConversion(request: logPinterestConversionRequest)
                        
                        // If logPinterestConversionResponse didLog is true set pinterestConversionLoggedOnce in user defaults to true
                        if logPinterestConversionResponse.body.didLog {
                            UserDefaults.standard.set(true, forKey: Constants.UserDefaults.pinterestConversionLoggedOnce)
                            
                        }
                    } catch {
                        // TODO: Handle errors
                        print("Error logging pinterest conversion in UltraView... \(error)")
                    }
                }
            }
            
//            // Refresh receipt and try to get it if it's made available.. the delegate wasn't working but the refresh receipt seemed to make the receipt immidiately available here so maybe!
//            IAPManager.refreshReceipt()
//            
//            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
//                // Get the receipt if it's available.
//                if let appStoreReceiptURL = Bundle.main.appStoreReceiptURL,
//                   FileManager.default.fileExists(atPath: appStoreReceiptURL.path) {
//                    
//                    
//                    do {
//                        let receiptData = try Data(contentsOf: appStoreReceiptURL, options: .alwaysMapped)
//                        print(receiptData)
//                        
//                        
////                        let receiptString = receiptData.base64EncodedString(options: [])
//                        
//                        
//                        // Update tenjin with transaction originalID as String and receipt
//                        TenjinSDK.transaction(
//                            withProductName: product.displayName,
//                            andCurrencyCode: "USD",
//                            andQuantity: 1,
//                            andUnitPrice: NSDecimalNumber(decimal: product.price),
//                            andTransactionId: "\(transaction.originalID)",
//                            andReceipt: receiptData)
//                        
//                    } catch {
//                        print("Couldn't read receipt data with error: " + error.localizedDescription)
//                    }
//                } else {
//                    // Update tenjin without receipt
//                    TenjinSDK.transaction(
//                        withProductName: product.displayName,
//                        andCurrencyCode: "USD",
//                        andQuantity: 1,
//                        andUnitPrice: NSDecimalNumber(decimal: product.price))
//                }
//            }
            
//            // Log event_purchase to tenjin
//            TenjinSDK.sendEvent(withName: "event_purchase")
//            
//            // Log event_purchase_value to tenjin
//            TenjinSDK.sendEvent(withName: "event_purchase_value", andEventValue: "\(Int(NSInteger(truncating: product.price as NSNumber)))")
//            
//            // Log purchase to Facebook
//            AppEvents.shared.logEvent(.startTrial)
//            
//            // Log purchase to Adjust
//            let adjEvent = ADJEvent(eventToken: "event_initiate_trial")
//            adjEvent?.setRevenue(NSDecimalNumber(decimal: transaction.price ?? 0.0).doubleValue, currency: "USD")
//            Adjust.trackEvent(adjEvent)
//            
//            // Log purchase to AppsFlyer
//            AppsFlyerLib.shared().logEvent(AFEventPurchase,
//            withValues: [
//                AFEventParamContentId:"event_purchase_custom",
//                AFEventParamContentType : "category_subscription_purchases_custom",
//                AFEventParamRevenue: 200,
//                AFEventParamCurrency:"USD"
//            ]);
            
            if #available(iOS 16.1, *) {
                Task {
                    do {
                        try await SKAdNetwork.updatePostbackConversionValue(3, coarseValue: .low)
                    } catch {
                        print("Error updating postback conversion value in UltraView... \(error)")
                    }
                }
            } else {
                Task {
                    do {
                        try await SKAdNetwork.updatePostbackConversionValue(1)
                    } catch {
                        print("Error updating psotback conversion value in UltraVIew... \(error)")
                    }
                }
            }
            
//            // Update Branch
//            if let skTransaction = transaction as? SKPaymentTransaction {
//                let event = BranchEvent(name: "PURCHASE")
//                event.logEvent(with: skTransaction)
//            }
            
            // Register the transaction ID with the server
            try await premiumUpdater.registerTransaction(authToken: authToken, transactionID: transaction.originalID)

            
            // If premium on complete, do success haptic and dismiss
            if premiumUpdater.isPremium {
                // Do success haptic
                HapticHelper.doSuccessHaptic()
                
                // Dismiss
                DispatchQueue.main.async {
                    isShowing = false
                }
            }
        }
    }
    
}

#Preview {
    
    UltraView(isShowing: .constant(false))
        .environmentObject(PremiumUpdater())
        .environmentObject(ProductUpdater())
        .environmentObject(RemainingUpdater())
    
}
