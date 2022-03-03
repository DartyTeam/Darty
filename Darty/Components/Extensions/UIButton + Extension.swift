//
//  UIButton + Extension.swift
//  Darty
//
//  Created by Руслан Садыков on 19.06.2021.
//

import UIKit

extension UIButton {

    static let defaultButtonHeight: CGFloat = 56
    
    convenience init(title: String? = "") {
        self.init(type: .system)
        
        self.setTitle(title, for: .normal)
        self.setTitleColor(.white, for: .normal)
        
        self.titleLabel?.font = .sfProRounded(ofSize: 17, weight: .semibold)
        
        self.layer.cornerRadius = 10
        self.layer.cornerCurve = .continuous
            
        self.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25).cgColor
        self.layer.shadowRadius = 4
        self.layer.shadowOpacity = 1
        self.layer.shadowOffset = CGSize(width: 0, height: 4)
    }
    
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
        let blur = UIVisualEffectView(effect: UIBlurEffect(style: .light))
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

