//
//  UIBarButtonItem + Extension.swift
//  Darty
//
//  Created by Руслан Садыков on 15.06.2022.
//

import SafeSFSymbols
import UIKit

enum ButtonSymbolType {
    case big
    case normal
    case small

    var size: CGFloat {
        switch self {
        case .big:
            return 32
        case .normal:
            return 18
        case .small:
            return 14
        }
    }

    var weight: UIFont.Weight {
        switch self {
        case .big:
            return .bold
        case .normal:
            return .bold
        case .small:
            return .semibold
        }
    }
}

extension UIBarButtonItem {
    convenience init(symbol: SPSafeSymbol, type: ButtonSymbolType, target: UIViewController, action: Selector) {
        let image = UIImage(symbol)
            .withConfiguration(UIImage.SymbolConfiguration(font: .systemFont(
                ofSize: type.size,
                weight: type.weight
            ))).withTintColor(type == .normal ? Colors.Elements.element : Colors.Elements.secondaryElement)
        self.init(image: image, style: .plain, target: target, action: action)
    }
}
