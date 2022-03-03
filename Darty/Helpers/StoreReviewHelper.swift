//
//  StoreReviewHelper.swift
//  Darty
//
//  Created by Руслан Садыков on 08.09.2021.
//

import StoreKit

struct StoreReviewHelper {
    
    static func incrementAppOpenedCount() { // called from appdelegate didfinishLaunchingWithOptions:
        guard var appOpenCount = UserDefaults.standard.appOpenedCount else {
            UserDefaults.standard.appOpenedCount = 1
            return
        }
        appOpenCount += 1
        UserDefaults.standard.appOpenedCount = appOpenCount
    }
    
    static func checkAndAskForReview() {
        // Call this whenever appropriate.
        // This will not be shown everytime. Apple has some internal logic on how to show this.
        guard let appOpenCount = UserDefaults.standard.appOpenedCount else {
            UserDefaults.standard.appOpenedCount = 1
            return
        }
        
        switch appOpenCount {
        case 10,50:
            StoreReviewHelper().requestReview()
        case _ where appOpenCount%100 == 0 :
            StoreReviewHelper().requestReview()
        default:
            print("App run count is : \(appOpenCount)")
            break;
        }
        
    }
    
    func requestReview() {
        if #available(iOS 14.0, *) {
            if let scene = UIApplication.shared.currentScene {
                SKStoreReviewController.requestReview(in: scene)
            }
        } else {
            SKStoreReviewController.requestReview()
        }
    }
}

extension UIApplication {
    var currentScene: UIWindowScene? {
        connectedScenes
            .first { $0.activationState == .foregroundActive } as? UIWindowScene
    }
}
