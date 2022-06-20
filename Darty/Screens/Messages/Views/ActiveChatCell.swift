//
//  ActiveChatCell.swift
//  Darty
//
//  Created by Руслан Садыков on 06.07.2021.
//

import UIKit

final class ActiveChatCell: UICollectionViewCell, SelfConfiguringCell {

    // MARK: - ReuseId
    static var reuseId: String = reuseIdentifier

    // MARK: - Constants
    private enum Constants {
        static let countLabelFont: UIFont? = .sfProRounded(ofSize: 10, weight: .medium)
        static let usernameFont: UIFont? = .sfProRounded(ofSize: 14, weight: .semibold)
        static let lastMessageFont: UIFont? = .sfCompactDisplay(ofSize: 10, weight: .medium)
        static let timeFont: UIFont? = .sfCompactDisplay(ofSize: 10, weight: .medium)
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
        label.textColor = Colors.Text.main
        return label
    }()
    
    private let lastMessageLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.font = Constants.lastMessageFont
        label.textColor = Colors.Text.secondary
        return label
    }()
    
    private let countMessagesView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = Colors.Elements.secondaryElement
        view.isHidden = true
        view.layer.cornerRadius = 8
        return view
    }()
    
    private let countLabel: UILabel = {
        let label = UILabel()
        label.font = Constants.countLabelFont
        label.textColor = Colors.Text.onUnderlayers
        return label
    }()
    
    private let timeLabel: UILabel = {
        let label = UILabel()
        label.font = Constants.timeFont
        label.textColor = Colors.Text.secondary
        return label
    }()

    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        setupConstraints()
    }

    // MARK: - Lifecicle
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        setupShadows()
    }
    
    func configure<U>(with value: U) where U : Hashable {
        guard let chat: RecentChatModel = value as? RecentChatModel else { return }
        
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
            if chat.unreadCounter > 99 {
                countLabel.text = "🤯"
            } else {
                let unreadCount = String(chat.unreadCounter)
                countLabel.text = unreadCount
            }
  
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
        layer.borderColor = Colors.Elements.secondaryElement.cgColor
        backgroundColor = Colors.Backgorunds.plate
        layer.cornerRadius = Constants.cellHeight / 2
        clipsToBounds = true
        layer.masksToBounds = false
        setupShadows()
    }

    private func setupShadows() {
//        layer.shadowColor = isDarkMode ?  UIColor.white.withAlphaComponent(0.2).cgColor : UIColor(red: 0, green: 0, blue: 0, alpha: 0.1).cgColor
//        layer.shadowRadius = 10
//        layer.shadowOpacity = 1
//        layer.shadowOffset = CGSize(width: 0, height: 4)
//        layer.shadowPath = UIBezierPath(roundedRect: self.bounds, cornerRadius: self.layer.cornerRadius).cgPath
//        //           layer.shouldRasterize = true
//        //           layer.rasterizationScale = UIScreen.main.scale

        layer.masksToBounds = false
           layer.shadowColor = Colors.Elements.secondaryElement.withAlphaComponent(0.5).cgColor
           layer.shadowOpacity = 1
           layer.shadowOffset = .zero
        layer.shadowRadius = 22

           layer.shadowPath = UIBezierPath(rect: self.bounds).cgPath
           layer.shouldRasterize = true
           layer.rasterizationScale = UIScreen.main.scale
    }
}

// MARK: - Setup constraints
extension ActiveChatCell {
    
    private func setupConstraints() {
        contentView.addSubview(userImageView)
        contentView.addSubview(usernameLabel)
        contentView.addSubview(lastMessageLabel)
        let spacer = UIView()
        let countAndTimeStackView = UIStackView(
            arrangedSubviews: [countMessagesView, timeLabel],
            axis: .vertical,
            spacing: 3
        )
        let horizontalStackView = UIStackView(arrangedSubviews: [spacer, countAndTimeStackView], axis: .horizontal, spacing: 0)
        countAndTimeStackView.alignment = .center
        countAndTimeStackView.distribution = .fillProportionally
        contentView.addSubview(horizontalStackView)
        countMessagesView.addSubview(countLabel)
        
        userImageView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().offset(12)
            make.size.equalTo(Constants.userImageSize)
            make.top.bottom.equalToSuperview().inset(10)
        }

        horizontalStackView.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-12)
            make.top.bottom.equalToSuperview().inset(16)
        }
        
        countLabel.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview().inset(2)
            make.left.right.equalToSuperview().inset(5)
        }
        
        usernameLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(10)
            make.left.equalTo(userImageView.snp.right).offset(8)
            make.right.equalTo(horizontalStackView.snp.left).offset(-8)
        }
        
        lastMessageLabel.snp.makeConstraints { make in
            make.top.equalTo(usernameLabel.snp.bottom).offset(2)
            make.left.equalTo(userImageView.snp.right).offset(8)
            make.right.equalTo(horizontalStackView.snp.left).offset(-8)
            make.bottom.lessThanOrEqualToSuperview().offset(-10)
        }
    }
}
