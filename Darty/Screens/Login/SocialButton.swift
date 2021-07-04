//
//  SocialButton.swift
//  Darty
//
//  Created by Руслан Садыков on 04.07.2021.
//

import UIKit

enum SocialLogin {
    case google
    case apple
    case facebook
    
    var logo: UIImage? {
        switch self {
        case .google:
            return UIImage(named: "google.logo")
        case .apple:
            return UIImage(named: "apple.logo")
        case .facebook:
            return UIImage(named: "facebook.logo")
        }
    }
    
    var backgroundColor: UIColor {
        switch self {
        
        case .google:
            return #colorLiteral(red: 0.9215686275, green: 0.262745098, blue: 0.2078431373, alpha: 1)
        case .apple:
            return #colorLiteral(red: 0.768627451, green: 0.768627451, blue: 0.768627451, alpha: 1)
        case .facebook:
            return #colorLiteral(red: 0.09411764706, green: 0.4666666667, blue: 0.9490196078, alpha: 1)
        }
    }
}

final class SocialButton: UIControl {
    
    // MARK: - UI Elements
    private let iconView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let activityIndicator: UIActivityIndicatorView = {
        let activityIndicatorView = UIActivityIndicatorView(style: .medium)
        activityIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        activityIndicatorView.hidesWhenStopped = true
        activityIndicatorView.color = .white
        return activityIndicatorView
    }()
    
    // MARK: - Properties
    private let social: SocialLogin!
    
    // MARK: - Lifecycle
    init(social: SocialLogin) {
        self.social = social
        super.init(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        
        iconView.image = social.logo
        self.backgroundColor = social.backgroundColor
        
        setupView()
        setupConstraints()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        layer.cornerRadius = self.frame.height / 2
        layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25).cgColor
        layer.shadowRadius = 4
        layer.shadowOpacity = 1
        layer.shadowOffset = CGSize(width: 0, height: 4)
        
        addSubview(iconView)
        addSubview(activityIndicator)
    }
    
    private func setupConstraints() {
        if social == .facebook {
            NSLayoutConstraint.activate([
                iconView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
                iconView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            ])
        } else {
            NSLayoutConstraint.activate([
                iconView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
                iconView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            ])
        }
        
        let xCenterConstraint = NSLayoutConstraint(item: self, attribute: .centerX, relatedBy: .equal, toItem: activityIndicator, attribute: .centerX, multiplier: 1, constant: 0)
        self.addConstraint(xCenterConstraint)
        
        let yCenterConstraint = NSLayoutConstraint(item: self, attribute: .centerY, relatedBy: .equal, toItem: activityIndicator, attribute: .centerY, multiplier: 1, constant: 0)
        self.addConstraint(yCenterConstraint)
    }
    
    override func endTracking(_ touch: UITouch?, with event: UIEvent?) {
        animate()
        showLoading()
//        UIView.animate(withDuration: 1, animations: { () -> Void in
//
//            self.iconView.transform = CGAffineTransform.init(scaleX: 0, y: 0)
//        })
    }
    
    func animate(completion: (() -> Void)? = nil) {
        isUserInteractionEnabled = false
        transform = CGAffineTransform(scaleX: 0.6, y: 0.6)
        
        UIView.animate(withDuration: 2.0,
                       delay: 0,
                       usingSpringWithDamping: CGFloat(0.20),
                       initialSpringVelocity: CGFloat(6.0),
                       options: UIView.AnimationOptions.allowUserInteraction,
                       animations: {
                        self.transform = CGAffineTransform.identity
                       },
                       completion: { _ in
                        completion?()
                 
                       }
        )
    }
    
    private func showLoading() {
        iconView.isHidden = true
        activityIndicator.startAnimating()
    }

    func hideLoading() {
        iconView.isHidden = false
        activityIndicator.stopAnimating()
        isUserInteractionEnabled = true
    }
}
