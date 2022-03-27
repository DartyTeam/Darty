//
//  String + Extension.swift
//  Darty
//
//  Created by Руслан Садыков on 03.07.2021.
//

import UIKit

extension String {
    func textToImage(bgColor: UIColor = .clear, needMoreSmallText: Bool = false) -> UIImage? {
        let nsString = (self as NSString)
        let fontSize: CGFloat = 1024
        let font = UIFont.systemFont(ofSize: fontSize) // you can change your font size here
        let stringAttributes = [NSAttributedString.Key.font: font]
        let imageSize = nsString.size(withAttributes: stringAttributes)
        let changedWidth = imageSize.width * (needMoreSmallText ? 1.5 : 1)
        let changedHeight = imageSize.height * (needMoreSmallText ? 1.5 : 1)
        let changedImageSize = CGSize(width: changedWidth, height:  changedHeight)
        UIGraphicsBeginImageContextWithOptions(changedImageSize, false, 0) //  begin image context
        bgColor.set() // clear background
        UIRectFill(CGRect(origin: CGPoint(), size: changedImageSize)) // set rect size Это цветной фон
        if needMoreSmallText {
            nsString.draw(at: CGPoint(x: changedWidth / 6, y: changedHeight / 6), withAttributes: stringAttributes) // draw text within rect
        } else {
            nsString.draw(at: CGPoint.zero, withAttributes: stringAttributes)
        }

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
