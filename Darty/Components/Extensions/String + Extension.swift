//
//  String + Extension.swift
//  Darty
//
//  Created by Руслан Садыков on 03.07.2021.
//

import UIKit

extension String {
    func textToImage(bgColor: UIColor = .clear) -> UIImage? {
        let nsString = (self as NSString)
        let font = UIFont.systemFont(ofSize: 1024) // you can change your font size here
        let stringAttributes = [NSAttributedString.Key.font: font]
        let imageSize = nsString.size(withAttributes: stringAttributes)

        UIGraphicsBeginImageContextWithOptions(imageSize, false, 0) //  begin image context
        bgColor.set() // clear background
        UIRectFill(CGRect(origin: CGPoint(), size: imageSize)) // set rect size
        nsString.draw(at: CGPoint.zero, withAttributes: stringAttributes) // draw text within rect
        let image = UIGraphicsGetImageFromCurrentImageContext() // create image from context
        UIGraphicsEndImageContext() //  end image context

        return image ?? UIImage()
    }
}

extension RangeReplaceableCollection where Self: StringProtocol {
    var digits: Self {
        return filter(("0"..."9").contains)
    }
}

extension String {
    func isEmptyOrWhitespaceOrNewLines() -> Bool {
        
        // Check empty string
        if self.isEmpty {
            return true
        }
        // Trim and check empty string
        return (self.trimmingCharacters(in: .whitespacesAndNewlines) == "")
    }
}

extension Optional where Wrapped == String {
    func isEmptyOrWhitespaceOrNewLines() -> Bool {
        // Check nil
        guard let this = self else { return true }
        
        // Check empty string
        if this.isEmpty {
            return true
        }
        // Trim and check empty string
        return (this.trimmingCharacters(in: .whitespacesAndNewlines) == "")
    }
}
