//
//  UIApplication + Extension.swift
//  Darty
//
//  Created by Руслан Садыков on 28.06.2021.
//

import UIKit

extension UIApplication {
        
    class func topViewController(_ viewController: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        if let nav = viewController as? UINavigationController {
            return topViewController(nav.visibleViewController)
        } else if let tab = viewController as? UITabBarController {
            if let selected = tab.selectedViewController {
                return topViewController(selected)
            }
        } else if let presented = viewController?.presentedViewController {
            return topViewController(presented)
        }
        
        return viewController
    }
}
