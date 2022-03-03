//
//  UserCell.swift
//  Darty
//
//  Created by Руслан Садыков on 21.07.2021.
//

import UIKit
import SDWebImage

final class UserCell: UICollectionViewCell {
    
    private enum Constants {
        static let nameFont: UIFont? = .sfProDisplay(ofSize: 12, weight: .semibold)
        static let ratingFont: UIFont? = .sfProRounded(ofSize: 12, weight: .semibold)
        static let userImageSize: CGFloat = 44
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
    
    let userRatingLabel: UILabel = {
        let label = UILabel()
        label.font = Constants.ratingFont
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .secondarySystemBackground
        self.layer.cornerRadius = 20
        setupConstraints()
    }
    
    func configure(with user: UserModel) {
        userImageView.sd_setImage(with: URL(string: user.avatarStringURL), completed: { [weak self] image, error, cacheType, url in
            self?.userImageView.focusOnFaces = true
        })
        usernameLabel.text = user.username
        userRatingLabel.text = "0.0 *"
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Setup constraints
extension UserCell {
    private func setupConstraints() {
        addSubview(userImageView)
        addSubview(usernameLabel)
        addSubview(userRatingLabel)
        
        userImageView.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview().inset(6)
            make.left.equalToSuperview().offset(8)
            make.size.equalTo(Constants.userImageSize)
        }
        
        usernameLabel.snp.makeConstraints { make in
            make.left.equalTo(userImageView.snp.right).offset(8)
            make.centerY.equalToSuperview().offset(-8)
            make.right.equalToSuperview().offset(-8)
        }
        
        userRatingLabel.snp.makeConstraints { make in
            make.left.equalTo(usernameLabel.snp.left)
            make.centerY.equalToSuperview().offset(8)
            make.right.equalToSuperview().offset(-8)
        }
    }
}
