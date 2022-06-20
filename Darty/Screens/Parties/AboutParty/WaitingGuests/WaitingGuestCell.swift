//
//  WaitingGuestCell.swift
//  Darty
//
//  Created by Руслан Садыков on 22.07.2021.
//

import UIKit

class WaitingGuestCell: UICollectionViewCell, SelfConfiguringCell {
    
    static var reuseId: String = reuseIdentifier
    
    private enum Constants {
        static let nameFont: UIFont? = .sfProDisplay(ofSize: 12, weight: .semibold)
        static let ratingFont: UIFont? = .sfProRounded(ofSize: 12, weight: .semibold)
        static let ageFont: UIFont? = .sfProRounded(ofSize: 12, weight: .semibold)
        static let userImageSize: CGFloat = 44
        static let messageFont: UIFont? = .sfProText(ofSize: 10, weight: .regular)
    }
    
    // MARK: - UI Elements
    private let userImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.cornerRadius = Constants.userImageSize / 2
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.backgroundColor = .systemGray
        return imageView
    }()
    
    private let usernameLabel: UILabel = {
        let label = UILabel()
        label.font = Constants.nameFont
        label.text = "Имя"
        return label
    }()
    
    private let ageLabel: UILabel = {
        let label = UILabel()
        label.font = Constants.ageFont
        label.text = "00"
        return label
    }()
    
    private lazy var nameAgeStackView: UIStackView = {
        let spacingView = UIView()
        let stackView = UIStackView(arrangedSubviews: [usernameLabel, ageLabel, spacingView], axis: .horizontal, spacing: 4)
        stackView.alignment = .leading
        stackView.distribution = .fill
        return stackView
    }()
    
    private let userRatingLabel: UILabel = {
        let label = UILabel()
        label.font = Constants.ratingFont
        return label
    }()
    
    let acceptButton: DButton = {
        let button = DButton(title: "Принять 􀆅")
        return button
    }()
    
    let denyButton: DButton = {
        let button = DButton(title: "Отклонить 􀆄")
        button.backgroundColor = Colors.Elements.secondaryElement
        return button
    }()
    
    private let messageLabel: UILabel = {
        let label = UILabel()
        label.font = Constants.messageFont
        label.numberOfLines = 0
        return label
    }()
    
    // MARK: - Properties
    private var user: UserModel!
    
    // MARK: - Lifecycle
    func configure<P>(with value: P) where P : Hashable {
        
        guard let user: UserModel = value as? UserModel else { return }
        self.user = user
        
        if user.avatarStringURL != "" {
            userImageView.setImage(stringUrl: user.avatarStringURL)
        }
        
        usernameLabel.text = user.username

        ageLabel.text = String(user.birthday.age())
        
        userRatingLabel.text = "0.0 *"
                
        setupCustomizations()
        setupConstraints()
    }
    
    func addMessageFromUser(_ message: String) {
        messageLabel.text = message
    }

    private func setupCustomizations() {
        backgroundColor = .systemBackground
        
        layer.shadowColor = UIColor(.black).cgColor
        layer.shadowRadius = 20
        layer.shadowOpacity = 0.5
        layer.shadowOffset = CGSize(width: -5, height: 10)
        
        layer.cornerRadius = 20
    }
}

// MARK: - Setup constraints
extension WaitingGuestCell {
    
    private func setupConstraints() {
        let buttonStackView = UIStackView(arrangedSubviews: [denyButton, acceptButton], axis: .horizontal, spacing: 20)
        buttonStackView.distribution = .fillEqually
        
        addSubview(nameAgeStackView)
        addSubview(userRatingLabel)
        addSubview(buttonStackView)
        
        addSubview(userImageView)
        addSubview(messageLabel)
        
        userImageView.snp.makeConstraints { make in
            make.top.left.equalToSuperview().inset(12)
            make.size.equalTo(Constants.userImageSize)
        }
                
        nameAgeStackView.snp.makeConstraints { make in
            make.centerY.equalTo(userImageView.snp.centerY).offset(-14)
            make.left.equalTo(userImageView.snp.right).offset(8)
            make.right.equalToSuperview().offset(-44)
            // Без width не будет отображаться возраст при очень длинном, не вмещающимся, имени
            make.width.equalTo(500)
            make.height.equalTo(10)
        }
        
        userRatingLabel.snp.makeConstraints { make in
            make.centerY.equalTo(nameAgeStackView.snp.centerY)
            make.right.equalToSuperview().inset(12)
        }
        
        messageLabel.snp.makeConstraints { make in
            make.left.equalTo(nameAgeStackView.snp.left)
            make.top.equalTo(nameAgeStackView.snp.bottom).offset(2)
            make.right.equalToSuperview().inset(12)
            make.bottom.lessThanOrEqualTo(userImageView.snp.bottom)
        }
        
        buttonStackView.snp.makeConstraints { (make) in
//            make.top.equalTo(userImageView.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(16)
            make.height.equalTo(44)
            make.bottom.equalToSuperview().inset(12)
        }
    }
}
