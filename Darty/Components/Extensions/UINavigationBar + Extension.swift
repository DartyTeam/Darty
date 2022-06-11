//
//  UINavigationBar + Extension.swift
//  Darty
//
//  Created by Руслан Садыков on 02.07.2021.
//

import UIKit

extension UINavigationBar {
    func setup(withColor color: UIColor, withClear: Bool) {
        let attrs: [NSAttributedString.Key : Any] = [
            .font: UIFont.sfProDisplay(ofSize: 22, weight: .semibold) ?? .systemFont(ofSize: 22)
        ]
        let appearance = UINavigationBarAppearance()

        let appearanceWhenScrolling = UINavigationBarAppearance()
        appearanceWhenScrolling.configureWithDefaultBackground()
        appearanceWhenScrolling.titleTextAttributes = attrs

        if withClear {
            appearance.configureWithTransparentBackground()
            appearance.titlePositionAdjustment = UIOffset(horizontal: 0, vertical: 2)
            appearance.titleTextAttributes = attrs
            standardAppearance = appearanceWhenScrolling
            compactAppearance = appearance
            scrollEdgeAppearance = appearance
        } else {
            appearance.configureWithDefaultBackground()
            appearance.titlePositionAdjustment = UIOffset(horizontal: 0, vertical: 2)
            appearance.titleTextAttributes = attrs
            standardAppearance = appearance
            compactAppearance = appearance
            scrollEdgeAppearance?.configureWithDefaultBackground()
        }
    }
}
