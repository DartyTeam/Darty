//
//  UIButton + Extension.swift
//  Darty
//
//  Created by Руслан Садыков on 19.06.2021.
//

import UIKit

extension UIButton {

    // Add touch area
    fileprivate struct UIButtonAssociatedKeys {
        static var addedTouchArea: CGFloat = 0
    }

    var addedTouchArea: CGFloat? {
        get {
            return objc_getAssociatedObject(self, &UIButtonAssociatedKeys.addedTouchArea) as? CGFloat
        }
        set {
            objc_setAssociatedObject(self, &UIButtonAssociatedKeys.addedTouchArea, newValue, .OBJC_ASSOCIATION_COPY)
        }
    }

    open override func point(inside point: CGPoint, with _: UIEvent?) -> Bool {
        let area = self.bounds.insetBy(dx: -(addedTouchArea ?? 0), dy: -(addedTouchArea ?? 0))
        return area.contains(point)
    }

    func addBlurEffect() {
        let blur = BlurEffectView()
        blur.isUserInteractionEnabled = false
        self.insertSubview(blur, at: 0)
        blur.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        if let imageView = self.imageView {
            self.bringSubviewToFront(imageView)
        }
        blur.clipsToBounds = true
    }
}
