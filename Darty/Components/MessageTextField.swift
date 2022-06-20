//
//  MessageTextField.swift
//  Darty
//
//  Created by Руслан Садыков on 23.07.2021.
//

import UIKit

final class MessageTextField: UITextField {

    // MARK: - Constants
    static let defaultHeight: CGFloat = 44
    
    // MARK: - UI Elements
    let sendButton = UIButton(type: .system)
    let smileButton = UIButton(type: .system)

    // MARK: - Properties
    private var selectedEmoji = false

    override init(frame: CGRect) {
        super.init(frame: frame)

        textColor = Colors.Text.main
        backgroundColor = Colors.Backgorunds.inputView
        setPlaceHolderTextColor(Colors.Text.placeholder)
        placeholder = "Введите сообщение..."
        font = UIFont.sfProDisplay(ofSize: 14, weight: .regular)
        layer.cornerRadius = 22
        
        clipsToBounds = false
        
        layer.borderColor = Colors.Elements.line.cgColor
        layer.borderWidth = 1
//        applySketchShadow(color: #colorLiteral(red: 0.7411764706, green: 0.7411764706, blue: 0.7411764706, alpha: 1), alpha: 50, x: 0, y: 0, blur: 12, spread: -3)

        let smileImage = UIImage(.face.smiling).withConfiguration(UIImage.SymbolConfiguration(font: .systemFont(
            ofSize: ButtonSymbolType.small.size,
            weight: ButtonSymbolType.small.weight
        )))
        smileButton.setImage(smileImage, for: .normal)
        
        leftView = smileButton
        leftView?.frame = CGRect(x: 0, y: 0, width: 19, height: 19)
        leftViewMode = .always
        
        sendButton.setImage(UIImage(named: "paperplane")?.withRenderingMode(.alwaysOriginal), for: .normal)
        sendButton.isHidden = true

        rightView = sendButton
        rightView?.frame = CGRect(x: 0, y: 0, width: 19, height: 19)
        rightViewMode = .always
        
        smileButton.addTarget(self, action: #selector(openEmojis), for: .touchUpInside)

        self.addTarget(
            self,
            action: #selector(self.textFieldSelected),
            for: [.editingDidBegin]
        )
        self.addTarget(
            self,
            action: #selector(self.textFieldDeselected),
            for: [.editingDidEnd, .editingDidEndOnExit, .touchUpOutside]
        )
        self.addTarget(self, action: #selector(textFieldEditingAction), for: .allEditingEvents)
    }

    @objc private func textFieldSelected() {
        animateBorderColor(toColor: Colors.Elements.element, duration: 0.3)
    }

    @objc private func textFieldDeselected() {
        animateBorderColor(toColor: Colors.Elements.line, duration: 0.3)
        selectedEmoji = false
    }

    @objc private func textFieldEditingAction() {
        sendButton.isHidden = text?.isEmpty ?? true
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
