//
//  ActiveChatCell.swift
//  Darty
//
//  Created by Руслан Садыков on 06.07.2021.
//

import UIKit
import SDWebImage

final class ActiveChatCell: UICollectionViewCell, SelfConfiguringCell {
    
    static var reuseId: String = reuseIdentifier
    
    private enum Constants {
        static let usernameFont: UIFont? = .sfProRounded(ofSize: 14, weight: .semibold)
        static let lastMessageFont: UIFont? = .sfCompactDisplay(ofSize: 10, weight: .medium)
        static let lastMessageColor: UIColor = #colorLiteral(red: 0.5921568627, green: 0.5921568627, blue: 0.5921568627, alpha: 1)
    }
    
    // MARK: - UI Elements
    private lazy var userImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.cornerRadius = self.layer.cornerRadius
        imageView.clipsToBounds = true
        return imageView
    }()
    
    private let usernameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = Constants.usernameFont
        return label
    }()
    
    private let lastMessageLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.font = Constants.lastMessageFont
        return label
    }()
    
    private let countMessagesView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .systemTeal
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        setupConstraints()
    }
    
    func configure<U>(with value: U) where U : Hashable {
        guard let chat: ChatModel = value as? ChatModel else { return }
        userImageView.sd_setImage(with: URL(string: chat.friendAvatarStringUrl), completed: nil)
        usernameLabel.text = chat.friendUsername
        lastMessageLabel.text = chat.lastMessageContent
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        backgroundColor = .secondarySystemBackground
        layer.cornerRadius = 10
        clipsToBounds = true
    }
}

// MARK: - Setup constraints
extension ActiveChatCell {
    
    private func setupConstraints() {
        addSubview(userImageView)
        addSubview(usernameLabel)
        addSubview(lastMessageLabel)
        addSubview(countMessagesView)
        
        NSLayoutConstraint.activate([
            userImageView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 12),
            userImageView.topAnchor.constraint(equalTo: self.topAnchor, constant: 10),
            userImageView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -10),
            userImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            userImageView.heightAnchor.constraint(equalToConstant: 44),
            userImageView.widthAnchor.constraint(equalToConstant: 44)
        ])
        
        NSLayoutConstraint.activate([
            countMessagesView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -12),
            countMessagesView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            countMessagesView.heightAnchor.constraint(equalToConstant: 20),
            countMessagesView.widthAnchor.constraint(equalToConstant: 20),
        ])
        
        NSLayoutConstraint.activate([
            usernameLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 12),
            usernameLabel.leadingAnchor.constraint(equalTo: userImageView.trailingAnchor, constant: 8),
            usernameLabel.trailingAnchor.constraint(equalTo: countMessagesView.leadingAnchor, constant: -8)
        ])
        
        NSLayoutConstraint.activate([
            lastMessageLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -12),
            lastMessageLabel.leadingAnchor.constraint(equalTo: userImageView.trailingAnchor, constant: 8),
            lastMessageLabel.trailingAnchor.constraint(equalTo: countMessagesView.leadingAnchor, constant: -8)
        ])
    }
}
