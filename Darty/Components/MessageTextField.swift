//
//  MessageTextField.swift
//  Darty
//
//  Created by Руслан Садыков on 23.07.2021.
//

import UIKit

enum MessageSendButtonColor {
    case tealBlue
    case orangeYellow
}

final class MessageTextField: UITextField {
    
    let sendButton = UIButton(type: .system)
    let smileButton = UIButton(type: .system)
    
    var color: MessageSendButtonColor = .tealBlue {
        didSet {
            switch color {
            case .tealBlue:
                tintColor = .systemTeal
            case .orangeYellow:
                sendButton.setImage(UIImage(named: "sendYellowIcon")?.withRenderingMode(.alwaysOriginal), for: .normal)
                smileButton.setImage(UIImage(systemName: "smiley")?.withTintColor(.systemOrange, renderingMode: .alwaysOriginal), for: .normal)
                tintColor = .systemOrange
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .white
        placeholder = "Введите сообщение..."
        font = UIFont.sfProDisplay(ofSize: 14, weight: .regular)
        clearButtonMode = .whileEditing
        layer.cornerRadius = 18
        
        clipsToBounds = false
        
        layer.borderColor = UIColor(red: 189, green: 189, blue: 189, alpha: 40).cgColor
        layer.borderWidth = 0.2
        applySketchShadow(color: #colorLiteral(red: 0.7411764706, green: 0.7411764706, blue: 0.7411764706, alpha: 1), alpha: 50, x: 0, y: 0, blur: 12, spread: -3)
        
        smileButton.setImage(UIImage(systemName: "smiley"), for: .normal)
        
        leftView = smileButton
        leftView?.frame = CGRect(x: 0, y: 0, width: 19, height: 19)
        leftViewMode = .always
        
        sendButton.setImage(UIImage(named: "sendYellowIcon")?.withRenderingMode(.alwaysOriginal), for: .normal)
        
        rightView = sendButton
        rightView?.frame = CGRect(x: 0, y: 0, width: 19, height: 19)
        rightViewMode = .always
        
        smileButton.addTarget(self, action: #selector(openEmojis), for: .touchUpInside)
        
        addTarget(self, action: #selector(clearSelectedEmoji), for: .editingDidEnd)
    }
    
    var selectedEmoji = false
    
    @objc private func clearSelectedEmoji() {
        selectedEmoji = false
    }
    
    @objc private func openEmojis() {
        selectedEmoji = true
        reloadInputViews()
        becomeFirstResponder()
    }
    
    override var textInputMode: UITextInputMode? {
        if selectedEmoji {
            for mode in UITextInputMode.activeInputModes {
                if mode.primaryLanguage == "emoji" {
                    return mode
                }
            }
        }
        return nil
    }
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.insetBy(dx: 42, dy: 0)
    }
    
    override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.insetBy(dx: 42, dy: 0)
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.insetBy(dx: 42, dy: 0)
    }
    
    override func leftViewRect(forBounds bounds: CGRect) -> CGRect {
        var rect = super.leftViewRect(forBounds: bounds)
        rect.origin.x += 12
        return rect
    }
    
    override func rightViewRect(forBounds bounds: CGRect) -> CGRect {
        var rect = super.rightViewRect(forBounds: bounds)
        rect.origin.x += -12
        return rect
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
