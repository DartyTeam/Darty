//
//  UINavigationBar + Extension.swift
//  Darty
//
//  Created by Руслан Садыков on 02.07.2021.
//

import UIKit

extension UINavigationBar {
    
    func setup(withColor color: UIColor, withClear: Bool) {
        let attrs = [
            NSAttributedString.Key.font: UIFont.sfProDisplay(ofSize: 28, weight: .semibold)
        ]
        let appearance = UINavigationBarAppearance()
     
        if withClear {
            appearance.configureWithTransparentBackground()
            appearance.titlePositionAdjustment = UIOffset(horizontal: 0, vertical: 2)
            appearance.titleTextAttributes = attrs
            standardAppearance = appearance
            compactAppearance = appearance
            scrollEdgeAppearance = appearance
        } else {
            appearance.configureWithDefaultBackground()
            appearance.titlePositionAdjustment = UIOffset(horizontal: 0, vertical: 2)
            appearance.titleTextAttributes = attrs
            standardAppearance = appearance
            compactAppearance = appearance
            scrollEdgeAppearance = appearance
        }
    }
}
