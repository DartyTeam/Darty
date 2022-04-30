//
//  TextView.swift
//  Darty
//
//  Created by Руслан Садыков on 10.07.2021.
//

import UIKit

protocol TextViewDelegate {
    func textViewDidEndEditing(_ textView: UITextView)
}

class TextView: UIView {

    private enum Constants {
        static let textFont: UIFont? = .sfProText(ofSize: 14, weight: .regular)
        static let titleFont: UIFont? = .sfProDisplay(ofSize: 10, weight: .medium)
        static let unselectedBorderColor: CGColor = #colorLiteral(red: 0.768627451, green: 0.768627451, blue: 0.768627451, alpha: 0.5).cgColor
    }

    private let textView = UITextView()
    private var savedPlaceholder: String!
    
    var text = ""
    
    private var errorMessage = ""

    private var floatingLabel: UILabel!

    private var activeBorderColor: UIColor = .blue
    
    var delegate: TextViewDelegate?

    init(placeholder: String = "Описание", isEditable: Bool, color: UIColor) {
        super.init(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        self.savedPlaceholder = placeholder
        self.activeBorderColor = color
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
        textView.tintColor = activeBorderColor
        
        if textView.isEditable {
            textView.textColor = .placeholderText
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
        backgroundColor = .tertiarySystemBackground
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
        self.floatingLabel.textColor = activeBorderColor
    }
    
    private func setupBorder() {
        layer.cornerRadius = 8
        layer.cornerCurve = .continuous
        layer.borderColor = Constants.unselectedBorderColor
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
            floatingLabel.frame = CGRect(x: 0, y: 0, width: floatingLabel.frame.width+4, height: floatingLabel.frame.height+2)
            floatingLabel.textAlignment = .center
            floatingLabel.textColor = activeBorderColor
            addSubview(self.floatingLabel)
            layer.borderColor = self.activeBorderColor.cgColor

            NSLayoutConstraint.activate([
                floatingLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 12),
                floatingLabel.bottomAnchor.constraint(equalTo: self.topAnchor, constant: -4)
            ])
//        }
        // Floating label may be stuck behind text input. we bring it forward as it was the last item added to the view heirachy
        bringSubviewToFront(subviews.last!)

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
        self.layer.borderColor = Constants.unselectedBorderColor
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
        if textView.textColor == .placeholderText {
            textView.text = nil
            textView.textColor = .label
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
            textView.textColor = .placeholderText
            text = ""
        } else {
            floatingLabel.textColor = .label
            text = textView.text
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
            self.floatingLabel.textColor = .systemRed
            self.layer.borderColor = UIColor.systemRed.cgColor
        }
    }
}
