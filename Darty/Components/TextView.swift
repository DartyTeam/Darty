//
//  TextView.swift
//  Darty
//
//  Created by Руслан Садыков on 10.07.2021.
//

import UIKit

protocol TextViewDelegate: AnyObject {
    func textViewDidEndEditing(_ textView: UITextView)
}

final class TextView: UIView {

    private enum Constants {
        static let textFont: UIFont? = .sfProText(ofSize: 14, weight: .regular)
        static let titleFont: UIFont? = .textOnPlate
        static let unselectedBorderColor: UIColor = Colors.Elements.line
        static let activeBorderColor: UIColor = Colors.Elements.element
    }

    private let textView = UITextView()
    private var savedPlaceholder: String!
    
    var text = ""
    
    private var errorMessage = ""

    private var floatingLabel: UILabel!
    
    weak var delegate: TextViewDelegate?

    init(placeholder: String = "Описание", isEditable: Bool) {
        super.init(frame: .zero)
        self.savedPlaceholder = placeholder
        setupViews()
        setupFloatingLabel()
        setupBorder()
        setupShadow()
        setupTextView(isEditable: isEditable)
    }
    
    private func setupTextView(isEditable: Bool) {
        textView.delegate = self
        textView.font = Constants.textFont
        textView.dataDetectorTypes = UIDataDetectorTypes.link
        textView.isEditable = isEditable
        textView.tintColor = Constants.activeBorderColor
        
        if textView.isEditable {
            textView.textColor = Colors.Text.placeholder
            textView.font = .placeholder
            textView.text = savedPlaceholder
        }
        
        //        switch traitCollection.userInterfaceStyle {

        //        case .unspecified:
        //            textView.textColor = .black
        //        case .light:
        //            textView.textColor = .black
        //        case .dark:
        //            textView.textColor = .white
        //        @unknown default:
        //            textView.textColor = .black
        //        }
    }

    private func setupViews() {
        backgroundColor = Colors.Backgorunds.inputView
        addSubview(textView)
        textView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(8)
        }
    }

    override var backgroundColor: UIColor? {
        didSet {
            textView.backgroundColor = backgroundColor
        }
    }
    
    private func setupFloatingLabel() {
        self.floatingLabel = UILabel(frame: CGRect.zero)
        self.floatingLabel.textColor = Constants.activeBorderColor
    }
    
    private func setupBorder() {
        layer.cornerRadius = 10
        layer.cornerCurve = .continuous
        layer.borderColor = Constants.unselectedBorderColor.cgColor
        layer.borderWidth = 1
    }
    
    private func setupShadow() {
        layer.shadowColor = UIColor(red: 0.769, green: 0.769, blue: 0.769, alpha: 0.5).cgColor
        layer.shadowRadius = 5
        layer.shadowOpacity = 1
        layer.shadowOffset = CGSize(width: 0, height: 0)
    }

    @objc private func addFloatingLabel() {
        //        if textView.text == savedPlaceholder {
        floatingLabel.font = Constants.titleFont
        floatingLabel.text = self.savedPlaceholder
        floatingLabel.translatesAutoresizingMaskIntoConstraints = false
        floatingLabel.clipsToBounds = true
        floatingLabel.frame = CGRect(
            x: 0,
            y: 0,
            width: floatingLabel.frame.width + 4,
            height: floatingLabel.frame.height + 2
        )
        floatingLabel.textAlignment = .center

        UIView.transition(with: floatingLabel, duration: 0.3, options: .transitionCrossDissolve) {
            self.floatingLabel.textColor = Constants.activeBorderColor
        }
        addSubview(self.floatingLabel)
        animateBorderColor(toColor: Constants.activeBorderColor, duration: 0.3)

        NSLayoutConstraint.activate([
            floatingLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 12),
            floatingLabel.bottomAnchor.constraint(equalTo: self.topAnchor, constant: -4)
        ])
        //        }
        // Floating label may be stuck behind text input. we bring it forward as it was the last item added to the view heirachy
        bringSubviewToFront(subviews.last!)

        floatingLabel.alpha = 0
        floatingLabel.center.y += 25
        UIView.animate(withDuration: 0.3) {
            self.floatingLabel.center.y -= 25
            self.floatingLabel.alpha = 1
        }

        UIView.animate(withDuration: 0.3) {
            self.setNeedsDisplay()
        }
    }

    @objc private func removeFloatingLabel() {
        if textView.text == "" {
            UIView.animate(withDuration: 0.3) {
                self.floatingLabel.removeFromSuperview()
                self.textView.setNeedsDisplay()
            }
        }
        animateBorderColor(toColor: Constants.unselectedBorderColor, duration: 0.3)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

    }
    
    override func becomeFirstResponder() -> Bool {
        textView.becomeFirstResponder()
    }
}

extension TextView: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        addFloatingLabel()
        if textView.textColor == Colors.Text.placeholder {
            textView.text = nil
            textView.textColor = Colors.Text.main
            textView.font = Constants.textFont
            text = ""
        }
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        delegate?.textViewDidEndEditing(textView)
        
        removeFloatingLabel()
        if textView.text.isEmpty {
            if !errorMessage.isEmpty {
                setError(message: errorMessage)
            }
            textView.text = savedPlaceholder
            textView.textColor = Colors.Text.placeholder
            textView.font = .placeholder
            text = ""
        } else {
            UIView.transition(with: floatingLabel, duration: 0.3, options: .transitionCrossDissolve) {
                self.floatingLabel.textColor = Colors.Text.main
            }
            text = textView.text
            textView.font = Constants.textFont
        }
    }

    func textViewDidChange(_ textView: UITextView) {
        text = textView.text
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let newText = (textView.text as NSString).replacingCharacters(in: range, with: text)
        let numberOfChars = newText.count
        return numberOfChars < 1024
    }
    
    func setError(message: String) {
        errorMessage = message
        addFloatingLabel()
        Vibration.warning.vibrate()
        UIView.animate(withDuration: 0.3) {
            self.floatingLabel.text = message
            self.floatingLabel.textColor = Colors.Statuses.error
            self.layer.borderColor = Colors.Statuses.error.cgColor
        }
    }
}
