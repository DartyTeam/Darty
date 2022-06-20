//
//  UINavigationBar + Extension.swift
//  Darty
//
//  Created by Руслан Садыков on 02.07.2021.
//

import UIKit

extension UINavigationBar {
    func setup(withClear: Bool) {
        let attrs: [NSAttributedString.Key : Any] = [
            .font: UIFont.screenName
        ]
        let appearance = UINavigationBarAppearance()

        if withClear {
            appearance.configureWithTransparentBackground()
            appearance.titlePositionAdjustment = UIOffset(horizontal: 0, vertical: 2)
            appearance.titleTextAttributes = attrs
            scrollEdgeAppearance = appearance
            let appearanceWhenScrolling = UINavigationBarAppearance()
            appearanceWhenScrolling.configureWithDefaultBackground()
            appearanceWhenScrolling.titleTextAttributes = attrs
            appearanceWhenScrolling.backgroundEffect = .some(.init(style: .systemUltraThinMaterial))
            standardAppearance = appearanceWhenScrolling
        } else {
            appearance.configureWithDefaultBackground()
            appearance.titlePositionAdjustment = UIOffset(horizontal: 0, vertical: 2)
            appearance.titleTextAttributes = attrs
            standardAppearance = appearance
            scrollEdgeAppearance?.configureWithDefaultBackground()
        }

        compactAppearance = appearance
    }
}

func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    let appearance = UINavigationBarAppearance()
    appearance.configureWithTransparentBackground()
    appearance.backgroundColor = UIColor.clear
    appearance.backgroundEffect = UIBlurEffect(style: .light) // or dark

    let scrollingAppearance = UINavigationBarAppearance()
    scrollingAppearance.configureWithTransparentBackground()
    scrollingAppearance.backgroundColor = .white // your view (superview) color

    UINavigationBar.appearance().standardAppearance = appearance
    UINavigationBar.appearance().scrollEdgeAppearance = scrollingAppearance
    UINavigationBar.appearance().compactAppearance = scrollingAppearance

    return true
}
