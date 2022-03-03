//
//  TextFieldWithoutInteract.swift
//  Darty
//
//  Created by Руслан Садыков on 25.07.2021.
//

import UIKit

class TextFieldWithoutInteract: UITextField {
    
    override func caretRect(for position: UITextPosition) -> CGRect {
        return .zero
    }

    override func selectionRects(for range: UITextRange) -> [UITextSelectionRect] {
        return []
    }
    
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        // Disable copy, select all, paste
        if action == #selector(UIResponderStandardEditActions.copy(_:)) || action == #selector(UIResponderStandardEditActions.selectAll(_:)) || action == #selector(UIResponderStandardEditActions.paste(_:)) {
            return false
        }
        // Default
        return super.canPerformAction(action, withSender: sender)
    }
}
