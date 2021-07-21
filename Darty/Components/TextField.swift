//
//  TextField.swift
//  Darty
//
//  Created by Руслан Садыков on 09.07.2021.
//

import UIKit

final class TextField: UITextField {
    
    private enum Constants {
        static let textFont: UIFont? = .sfProText(ofSize: 14, weight: .regular)
        static let titleFont: UIFont? = .sfProDisplay(ofSize: 10, weight: .medium)
        static let unselectedBorderColor: UIColor = #colorLiteral(red: 0.768627451, green: 0.768627451, blue: 0.768627451, alpha: 0.5)
    }
    private var activeBorderColor: UIColor = UIColor.blue
    
    private var floatingLabel = UILabel(frame: CGRect.zero)
    private var button = UIButton(type: .custom)
    private var imageView = UIImageView(frame: CGRect.zero)
    
    private var errorMessage = ""
    private var savedPlaceholder: String
    
    override var text: String? {
        didSet {
            if text?.isEmpty ?? true {
                if subviews.contains(floatingLabel) {
                    removeFloatingLabel()
                }
            } else {
                if !subviews.contains(floatingLabel) {
                    addBlackFloating()
                }
            }
        }
    }

    init(color: UIColor, placeholder: String) {
        savedPlaceholder = placeholder
        super.init(frame: CGRect.zero)
        activeBorderColor = color
        
        self.placeholder = placeholder
        self.tintColor = color
   
        self.font = Constants.textFont
        
        self.addTarget(self, action: #selector(self.addFloatingLabel), for: [.editingDidBegin])
        self.addTarget(self, action: #selector(self.removeFloatingLabel), for: [.editingDidEnd, .editingDidEndOnExit, .touchUpOutside])
        
        setupFloatingLabel()
        setupViews()
        setupShadow()
        setupBorder()
    }
    
    private func setupFloatingLabel() {
        floatingLabel.textColor = activeBorderColor
    }
    
    private func setupBorder() {
        self.layer.borderWidth = 1
        self.layer.borderColor = Constants.unselectedBorderColor.cgColor
        self.layer.cornerRadius = 8
    }
    
    private func setupViews() {
        self.backgroundColor = .systemBackground
        self.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            heightAnchor.constraint(equalToConstant: 40)
        ])
    }
    
    private func setupShadow() {
        self.layer.shadowColor =  UIColor(red: 0.769, green: 0.769, blue: 0.769, alpha: 0.5).cgColor
        self.layer.shadowRadius = 5
        self.layer.shadowOpacity = 1
        self.layer.shadowOffset = CGSize(width: 0, height: 0)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // Add a floating label to the view on becoming first responder
    @objc private func addFloatingLabel() {

        if !self.subviews.contains(floatingLabel) {
            self.placeholder = ""
            
            floatingLabel.font = Constants.titleFont
            floatingLabel.text = savedPlaceholder
            floatingLabel.translatesAutoresizingMaskIntoConstraints = false
            floatingLabel.clipsToBounds = true
            floatingLabel.frame = CGRect(x: 0, y: 0, width: floatingLabel.frame.width + 4, height: floatingLabel.frame.height + 2)
            floatingLabel.textAlignment = .center
            addSubview(self.floatingLabel)

            NSLayoutConstraint.activate([
                floatingLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 12),
                floatingLabel.bottomAnchor.constraint(equalTo: self.topAnchor, constant: -4)
            ])
        
            floatingLabel.alpha = 0
            
            floatingLabel.center.y += 25
            UIView.animate(withDuration: 0.3) {
                self.floatingLabel.center.y -= 25
                self.floatingLabel.alpha = 1
            }
        }
        
        // Floating label may be stuck behind text input. we bring it forward as it was the last item added to the view heirachy
        self.bringSubviewToFront(subviews.last!)
     
        self.animateBorderColor(toColor: self.activeBorderColor, duration: 0.3)
        
        UIView.transition(with: floatingLabel, duration: 0.3, options: .transitionCrossDissolve) {
            self.floatingLabel.textColor = self.activeBorderColor
        }
        
        UIView.animate(withDuration: 0.3) {
            self.setNeedsDisplay()
        }
    }

    @objc private func removeFloatingLabel() {
        if self.text == "" {
            self.placeholder = savedPlaceholder
            if !errorMessage.isEmpty {
                self.animateBorderColor(toColor: UIColor.systemRed, duration: 0.3)
                UIView.transition(with: floatingLabel, duration: 0.3, options: .transitionCrossDissolve) {
                    self.floatingLabel.textColor = .systemRed
                    self.floatingLabel.text = self.errorMessage
                }
                return
            } else {
                UIView.animate(withDuration: 0.3) {
                    self.subviews.forEach{ $0.removeFromSuperview() }
                    self.setNeedsDisplay()
                }
            }
        }
        
        changeToBlack()
    }
    
    private func changeToBlack() {
        UIView.transition(with: floatingLabel, duration: 0.3, options: .transitionCrossDissolve) {
            self.floatingLabel.textColor = .black
            self.floatingLabel.text = self.savedPlaceholder
        }
        self.animateBorderColor(toColor: Constants.unselectedBorderColor, duration: 0.3)
    }
    
    private func addBlackFloating() {
        if !self.subviews.contains(floatingLabel) {
            
            floatingLabel.font = Constants.titleFont
            floatingLabel.text = savedPlaceholder
            floatingLabel.translatesAutoresizingMaskIntoConstraints = false
            floatingLabel.clipsToBounds = true
            floatingLabel.frame = CGRect(x: 0, y: 0, width: floatingLabel.frame.width + 4, height: floatingLabel.frame.height + 2)
            floatingLabel.textAlignment = .center
            addSubview(self.floatingLabel)

            NSLayoutConstraint.activate([
                floatingLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 12),
                floatingLabel.bottomAnchor.constraint(equalTo: self.topAnchor, constant: -4)
            ])
        
            floatingLabel.alpha = 0
            
            floatingLabel.center.y += 25
            UIView.animate(withDuration: 0.3) {
                self.floatingLabel.center.y -= 25
                self.floatingLabel.alpha = 1
            }
        }
        
        // Floating label may be stuck behind text input. we bring it forward as it was the last item added to the view heirachy
        self.bringSubviewToFront(subviews.last!)
        
        UIView.animate(withDuration: 0.3) {
            self.setNeedsDisplay()
        }
    }

    private func addViewPasswordButton() {
        self.button.setImage(UIImage(named: "ic_reveal"), for: .normal)
        self.button.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        self.button.frame = CGRect(x: 0, y: 16, width: 22, height: 16)
        self.button.clipsToBounds = true
        self.rightView = self.button
        self.rightViewMode = .always
        self.button.addTarget(self, action: #selector(self.enablePasswordVisibilityToggle), for: .touchUpInside)
    }

    func addImage(image: UIImage) {

        self.imageView.image = image
        self.imageView.frame = CGRect(x: 20, y: 0, width: 20, height: 20)
        self.imageView.translatesAutoresizingMaskIntoConstraints = true
        self.imageView.contentMode = .scaleAspectFit
        self.imageView.clipsToBounds = true

        DispatchQueue.main.async {
            self.leftView = self.imageView
            self.leftViewMode = .always
        }
    }

    @objc private func enablePasswordVisibilityToggle() {
        isSecureTextEntry.toggle()
        if isSecureTextEntry {
            self.button.setImage(UIImage(named: "ic_show"), for: .normal)
        }else{
            self.button.setImage(UIImage(named: "ic_hide"), for: .normal)
        }
    }
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.insetBy(dx: 12 , dy: 12)
     }

     // text position
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.insetBy(dx: 12 , dy: 12)
     }

    override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.insetBy(dx: 12, dy: 12)
     }
    
    func setError(message: String) {
        errorMessage = message
        addFloatingLabel()
        Vibration.warning.vibrate()
        self.animateBorderColor(toColor: UIColor.systemRed, duration: 0.3)
        UIView.transition(with: floatingLabel, duration: 0.3, options: .transitionCrossDissolve) {
            self.floatingLabel.textColor = .systemRed
            self.floatingLabel.text = message
        }
    }
}
