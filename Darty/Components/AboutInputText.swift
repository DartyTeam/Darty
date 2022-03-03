//
//  AboutInputText.swift
//  Darty
//
//  Created by Руслан Садыков on 07.07.2021.
//

import UIKit

class AboutInputText: UIView {
    
    let textView = UITextView()
    var savedPlaceholder: String!
    var placeholder: String!
    
    init(placeholder: String = "Введите текст...", isEditable: Bool) {
        super.init(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        self.savedPlaceholder = placeholder
        self.placeholder = placeholder
        textView.isEditable = isEditable
        
        customizeElements()
    }
    
    private func customizeElements() {
        
        addSubview(textView)
        
        textView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            textView.topAnchor.constraint(equalTo: self.topAnchor, constant: 8),
            textView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 8),
            textView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -8),
            textView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -8)
        ])
        
        textView.dataDetectorTypes = UIDataDetectorTypes.link

        textView.font = .sfProDisplay(ofSize: 16, weight: .regular)

        if textView.isEditable {
            textView.textColor = .lightGray
            textView.text = placeholder
        }
        backgroundColor = .white
        
        textView.delegate = self
        
        layer.cornerRadius = 18
        layer.borderColor = UIColor(red: 151, green: 151, blue: 151, alpha: 100).cgColor
        layer.borderWidth = 0.2
        
        let shadowView = UIView(frame: self.layer.bounds)
        addSubview(shadowView)
        applySketchShadow(color: #colorLiteral(red: 0.7411764706, green: 0.7411764706, blue: 0.7411764706, alpha: 1), alpha: 100, x: 0, y: 0, blur: 12, spread: -3)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    
    }
}

extension AboutInputText: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == .lightGray {
            textView.text = nil
            textView.textColor = .black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = savedPlaceholder
            textView.textColor = .lightGray
            placeholder = ""
        } else {
            placeholder = textView.text
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
        placeholder = textView.text
    }
}
