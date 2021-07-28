//
//  WaitingGuestCell.swift
//  Darty
//
//  Created by Руслан Садыков on 22.07.2021.
//

import UIKit
import SDWebImage

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
        return label
    }()
    
    private let userRatingLabel: UILabel = {
        let label = UILabel()
        label.font = Constants.ratingFont
        return label
    }()
    
    private let ageLabel: UILabel = {
        let label = UILabel()
        label.font = Constants.ageFont
        return label
    }()
    
    let acceptButton: UIButton = {
        let button = UIButton(title: "Принять 􀆅")
        button.backgroundColor = .systemOrange
        return button
    }()
    
    let denyButton: UIButton = {
        let button = UIButton(title: "Отклонить 􀆄")
        button.backgroundColor = .systemRed
        return button
    }()
    
    private let messageLabel: UILabel = {
        let label = UILabel()
        label.font = Constants.messageFont
        return label
    }()
    
    // MARK: - Properties
    private var user: UserModel!
    
    // MARK: - Lifecycle
    func configure<P>(with value: P) where P : Hashable {
        
        guard let user: UserModel = value as? UserModel else { return }
        self.user = user
        
        if user.avatarStringURL != "" {
            userImageView.sd_setImage(with: URL(string: user.avatarStringURL), completed: { [weak self] image, error, cacheType, url in
                self?.userImageView.focusOnFaces = true
            })
        }
        
        usernameLabel.text = user.username

        let now = Date()
        let calendar = Calendar.current
        let ageComponents = calendar.dateComponents([.year], from: user.birthday, to: now)
        ageLabel.text = String(ageComponents.year!)
        
        userRatingLabel.text = "0.0 *"
                
        setupCustomizations()
        setupConstraints()
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
        
        let nameAgeStackView = UIStackView(arrangedSubviews: [usernameLabel, ageLabel], axis: .horizontal, spacing: 4)
        nameAgeStackView.alignment = .leading
        let nameAgeRatingStackView = UIStackView(arrangedSubviews: [nameAgeStackView, userRatingLabel], axis: .horizontal, spacing: 8)
        
        addSubview(nameAgeRatingStackView)
        addSubview(buttonStackView)
        
        addSubview(userImageView)
        addSubview(messageLabel)
        
        userImageView.snp.makeConstraints { make in
            make.top.left.equalToSuperview().inset(12)
            make.size.equalTo(Constants.userImageSize)
        }
        
        nameAgeRatingStackView.snp.makeConstraints { make in
            make.centerY.equalTo(userImageView.snp.centerY).offset(-10)
            make.left.equalTo(userImageView.snp.right).offset(8)
            make.right.equalToSuperview().inset(12)
        }
        
//        ageLabel.snp.makeConstraints { (make) in
//            make.trailing.equalToSuperview().offset(-64)
//        }
        
        messageLabel.snp.makeConstraints { make in
            make.left.equalTo(nameAgeRatingStackView.snp.left)
            make.top.equalTo(nameAgeRatingStackView.snp.bottom).offset(8)
            make.right.equalToSuperview().inset(12)
            make.bottom.equalTo(userImageView.snp.bottom)
        }
        
        buttonStackView.snp.makeConstraints { (make) in
//            make.top.equalTo(userImageView.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(16)
            make.height.equalTo(44)
            make.bottom.equalToSuperview().inset(12)
        }
    }
}
