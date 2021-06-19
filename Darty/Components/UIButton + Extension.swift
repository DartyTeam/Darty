//
//  UIButton + Extension.swift
//  Darty
//
//  Created by Руслан Садыков on 19.06.2021.
//

import UIKit

extension UIButton {
    
    convenience init(title: String? = "", color: ButtonColors = .blue) {
        self.init(type: .system)
        
        self.setTitle(title, for: .normal)
        self.setTitleColor(.white, for: .normal)
        
        self.layer.cornerRadius = 10
            
        self.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25).cgColor
        self.layer.shadowRadius = 4
        self.layer.shadowOpacity = 1
        self.layer.shadowOffset = CGSize(width: 0, height: 4)
        
        switch color {

        case .red:
            self.backgroundColor = .systemRed
        case .blue:
            self.backgroundColor = .systemBlue
        case .purple:
            self.backgroundColor = .systemPurple
        case .green:
            self.backgroundColor = .systemGreen
        case .orange:
            self.backgroundColor = .systemOrange
        case .yellow:
            self.backgroundColor = .systemYellow
        }
        
    }
    
    enum ButtonColors {
        case red
        case blue
        case purple
        case green
        case orange
        case yellow
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
}
