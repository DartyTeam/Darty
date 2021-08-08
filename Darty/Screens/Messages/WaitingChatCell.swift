//
//  WaitingChatCell.swift
//  Darty
//
//  Created by Руслан Садыков on 07.07.2021.
//

import UIKit

protocol WaitingChatsNavigation: class {
    func removeWaitingChat(chat: ChatModel)
    func changeToActive(chat: ChatModel)
}

final class WaitingChatCell: UICollectionViewCell, SelfConfiguringCell {
        
    static var reuseId: String = reuseIdentifier
    
    let friendImageView: UIImageView = {
        let imageView = UIImageView()
        return imageView
    }()
    
    func configure<U>(with value: U) where U : Hashable {
        guard let chat: ChatModel = value as? ChatModel else { return }
        friendImageView.sd_setImage(with: URL(string: chat.friendAvatarStringUrl), completed: nil)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        backgroundColor = .yellow
        layer.cornerRadius = self.frame.size.height / 2
        clipsToBounds = true
    }
}

// MARK: - Setup constraints
extension WaitingChatCell {
    
    private func setupConstraints() {
        addSubview(friendImageView)
        
        friendImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}
