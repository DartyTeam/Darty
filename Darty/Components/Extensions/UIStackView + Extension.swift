//
//  UIStackView + Extension.swift
//  Darty
//
//  Created by Руслан Садыков on 07.07.2021.
//

import UIKit

extension UIStackView {
    convenience init(arrangedSubviews: [UIView] = [], axis: NSLayoutConstraint.Axis = .vertical, spacing: CGFloat = 0) {
        self.init(arrangedSubviews: arrangedSubviews)
        self.axis = axis
        self.spacing = spacing
    }
}
