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
        static let countLabelFont: UIFont? = .sfProRounded(ofSize: 10, weight: .medium)
        static let usernameFont: UIFont? = .sfProRounded(ofSize: 14, weight: .semibold)
        static let lastMessageFont: UIFont? = .sfCompactDisplay(ofSize: 10, weight: .medium)
        static let timeFont: UIFont? = .sfCompactDisplay(ofSize: 10, weight: .medium)
        static let lastMessageColor: UIColor = #colorLiteral(red: 0.5921568627, green: 0.5921568627, blue: 0.5921568627, alpha: 1)
        static let userImageSize: CGFloat = 44
        static let cellHeight: CGFloat = 64
    }
    
    // MARK: - UI Elements
    private lazy var userImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.cornerRadius = Constants.userImageSize / 2
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
        view.isHidden = true
        view.layer.cornerRadius = 8
        return view
    }()
    
    private let countLabel: UILabel = {
        let label = UILabel()
        label.font = Constants.countLabelFont
        label.textColor = .systemBackground
        return label
    }()
    
    private let timeLabel: UILabel = {
        let label = UILabel()
        label.font = Constants.timeFont
        label.textColor = Constants.lastMessageColor
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        setupConstraints()
    }
    
    func configure<U>(with value: U) where U : Hashable {
        guard let chat: RecentChatModel = value as? RecentChatModel else { return }
        
        print("asdkasdljasd: ", chat)
        
        if let imageUrl = URL(string: chat.avatarLink) {
            StorageService.shared.downloadImage(url: imageUrl) { [weak self] result in
                switch result {

                case .success(let image):
                    self?.userImageView.image = image
                    self?.userImageView.focusOnFaces = true
                case .failure(let error):
                    print("ERROR_LOG Error get chat image for url: ", chat.avatarLink, error)
                }
            }
        }
    
        usernameLabel.text = chat.receiverName
            
        lastMessageLabel.text = chat.lastMessageContent
        
        if chat.unreadCounter != 0 {
            countLabel.isHidden = false
            countMessagesView.isHidden = false
            let unreadCount = String(chat.unreadCounter)
            countLabel.text = unreadCount
            layer.borderWidth = 1
        } else {
            layer.borderWidth = 0
            countLabel.isHidden = true
            countMessagesView.isHidden = true
        }
        
        timeLabel.text = timeElapsed(chat.date)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        layer.borderColor = UIColor.systemTeal.cgColor
        backgroundColor = .systemBackground
        layer.cornerRadius = Constants.cellHeight / 2
        clipsToBounds = true
        layer.masksToBounds = false
        layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.1).cgColor
                layer.shadowRadius = 10
                layer.shadowOpacity = 1
                layer.shadowOffset = CGSize(width: 0, height: 4)

//           layer.shadowPath = UIBezierPath(rect: bounds).cgPath
//           layer.shouldRasterize = true
//           layer.rasterizationScale = UIScreen.main.scale
    }
}

// MARK: - Setup constraints
extension ActiveChatCell {
    
    private func setupConstraints() {
        addSubview(userImageView)
        addSubview(usernameLabel)
        addSubview(lastMessageLabel)
        addSubview(countMessagesView)
        countMessagesView.addSubview(countLabel)
        addSubview(timeLabel)
        
        userImageView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().offset(12)
            make.size.equalTo(Constants.userImageSize)
            make.top.bottom.equalToSuperview().inset(10)
        }
        
        countMessagesView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().inset(12)
//            make.size.equalTo(20)
        }
        
        countLabel.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview().inset(2)
            make.left.right.equalToSuperview().inset(5)
        }
        
        usernameLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(10)
            make.left.equalTo(userImageView.snp.right).offset(8)
            make.right.equalToSuperview().inset(64)
        }
        
        lastMessageLabel.snp.makeConstraints { make in
            make.top.equalTo(usernameLabel.snp.bottom).offset(2)
            make.left.equalTo(userImageView.snp.right).offset(8)
            make.right.equalTo(countMessagesView.snp.left).offset(-8)
            make.bottom.lessThanOrEqualToSuperview().offset(-10)
        }
        
        timeLabel.snp.makeConstraints { make in
            make.centerY.equalTo(usernameLabel.snp.centerY)
            make.right.equalTo(countMessagesView.snp.left).inset(-6)
        }
    }
}
