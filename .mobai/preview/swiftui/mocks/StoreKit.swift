// Generated from MobAI normalized Apple SDK IR.
// Module: StoreKit
// Extracted SDK modules: StoreKit, StoreKit.SKANError, StoreKit.SKAdImpression, StoreKit.SKAdNetwork, StoreKit.SKArcadeService, StoreKit.SKCloudServiceController, StoreKit.SKCloudServiceSetupViewController, StoreKit.SKDownload, StoreKit.SKDownloaderExtension, StoreKit.SKError, StoreKit.SKOverlay, StoreKit.SKOverlayConfiguration, StoreKit.SKOverlayTransitionContext, StoreKit.SKPayment, StoreKit.SKPaymentDiscount, StoreKit.SKPaymentQueue, StoreKit.SKPaymentTransaction, StoreKit.SKProduct, StoreKit.SKProductDiscount, StoreKit.SKProductStorePromotionController, StoreKit.SKProductsRequest, StoreKit.SKReceiptRefreshRequest, StoreKit.SKRequest, StoreKit.SKStoreProductViewController, StoreKit.SKStoreReviewController, StoreKit.SKStorefront, StoreKit.StoreKitDefines, _StoreKit_SwiftUI
// This project copy is editable; catalog expansion only appends missing declarations.

import Foundation
import SwiftUI






// mobai-ir-declaration: AppStore
public enum AppStore {
    public struct Environment: Hashable {
        public init() {}
    
        public var rawValue: String { "" }
    
        public init(rawValue value0: String) {}
    
        public static var production: AppStore.Environment { .init() }
    
        public static var sandbox: AppStore.Environment { .init() }
    
        public static var xcode: AppStore.Environment { .init() }
    
        public typealias RawValue = String
    }

    public static func requestReview(`in` value0: UIKit.UIWindowScene) {}
}

// mobai-ir-declaration: RequestReviewAction
public struct RequestReviewAction: Hashable {
    public init() {}
}

// mobai-ir-declaration: requestReview
public extension EnvironmentValues {
    public var requestReview: RequestReviewAction { .init() }
}
