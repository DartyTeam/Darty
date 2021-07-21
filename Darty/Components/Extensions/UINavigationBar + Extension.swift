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
            setBackgroundImage(UIImage(), for: .default)
            shadowImage = UIImage()
            isTranslucent = true
            backgroundColor = .clear
        } else {
            appearance.configureWithDefaultBackground()
            appearance.titleTextAttributes = attrs
            standardAppearance = appearance
            compactAppearance = appearance
            scrollEdgeAppearance = appearance
        }

      
        
        titleTextAttributes = attrs as [NSAttributedString.Key : Any]
        setTitleVerticalPositionAdjustment(2, for: .default)
    }
}
