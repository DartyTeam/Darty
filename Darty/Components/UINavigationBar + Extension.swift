//
//  UINavigationBar + Extension.swift
//  Darty
//
//  Created by Руслан Садыков on 02.07.2021.
//

import UIKit

extension UINavigationBar {
    
    func setup(withColor color: UIColor) {
        setBackgroundImage(UIImage(), for: .default)
        shadowImage = UIImage()
        isTranslucent = true
        backgroundColor = .clear
        let attrs = [
            NSAttributedString.Key.font: UIFont.sfProDisplay(ofSize: 28, weight: .semibold)
        ]

        titleTextAttributes = attrs
        setTitleVerticalPositionAdjustment(10, for: .default)
    }
}
