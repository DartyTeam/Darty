//
//  UIDevice + Extension.swift
//  Darty
//
//  Created by Руслан Садыков on 12.07.2021.
//

import UIKit

extension UIDevice {
    /// Returns `true` if the device has a notch
    var hasNotch: Bool {
          let bottom = UIApplication.shared.keyWindow?.safeAreaInsets.bottom ?? 0
          return bottom > 0
    }
}
