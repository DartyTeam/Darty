//
//  UIFont + Extension.swift
//  Darty
//
//  Created by Руслан Садыков on 02.07.2021.
//

import UIKit

extension UIFont {
    
    enum sfProRoundedWeight {
        case regular
        case medium
        case semibold
        case bold
    }
    
    enum sfProDisplayWeight {
        case regular
        case medium
        case semibold
    }
    
    enum sfProTextWeight {
        case regular
        case medium
        case semibold
        case bold
    }
    
    enum sfCompactDisplayWeight {
        case medium
        case thin
    }
    
    static func sfProRounded(ofSize size: CGFloat, weight: sfProRoundedWeight) -> UIFont? {
        switch weight {
        case .regular:
            return UIFont.init(name: "SFProRounded-Regular", size: size)
        case .medium:
            return UIFont.init(name: "SFProRounded-Medium", size: size)
        case .semibold:
            return UIFont.init(name: "SFProRounded-Semibold", size: size)
        case .bold:
            return UIFont.init(name: "SFProRounded-Bold", size: size)
        }
    }
    
    static func sfProDisplay(ofSize size: CGFloat, weight: sfProDisplayWeight) -> UIFont? {
        switch weight {
        case .regular:
            return UIFont.init(name: "SFProDisplay-Regular", size: size)
        case .medium:
            return UIFont.init(name: "SFProDisplay-Medium", size: size)
        case .semibold:
            return UIFont.init(name: "SFProDisplay-Semibold", size: size)
        }
    }
    
    static func sfProText(ofSize size: CGFloat, weight: sfProTextWeight) -> UIFont? {
        switch weight {
        case .regular:
            return UIFont.init(name: "SFProText-Regular", size: size)
        case .medium:
            return UIFont.init(name: "SFProText-Medium", size: size)
        case .semibold:
            return UIFont.init(name: "SFProText-Semibold", size: size)
        case .bold:
            return UIFont.init(name: "SFProText-Bold", size: size)
        }
    }
    
    static func sfCompactDisplay(ofSize size: CGFloat, weight: sfCompactDisplayWeight) -> UIFont? {
        switch weight {
        case .medium:
            return UIFont.init(name: "SFCompactDisplay-Medium", size: size)
        case .thin:
            return UIFont.init(name: "SFCompactDisplay-Thin", size: size)
        }
    }

    static let screenName = UIFont.sfProDisplay(ofSize: 24, weight: .semibold)
    static let title = UIFont.sfProRounded(ofSize: 16, weight: .bold)
    static let subtitle = UIFont.sfProDisplay(ofSize: 14, weight: .medium)
    static let textOnPlate = UIFont.sfProRounded(ofSize: 12, weight: .medium)
    static let message = UIFont.sfProText(ofSize: 12, weight: .regular)
    static let placeholder = UIFont.sfProText(ofSize: 14, weight: .regular)
    static let button = UIFont.sfProRounded(ofSize: 16, weight: .semibold)
    static let smallest = UIFont.sfProDisplay(ofSize: 8, weight: .medium)
}
