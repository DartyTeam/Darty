//
//  WaitingChatCell.swift
//  Darty
//
//  Created by Руслан Садыков on 07.07.2021.
//

import UIKit

final class WaitingChatCell: UICollectionViewCell, SelfConfiguringCell {
        
    static var reuseId: String = reuseIdentifier
    
    let friendImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()
    
    func configure<U>(with value: U) where U : Hashable {
        guard let chat: RecentChatModel = value as? RecentChatModel else { return }
        friendImageView.sd_setImage(with: URL(string: chat.avatarLink), completed: nil)
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
        layer.cornerRadius = self.frame.size.height / 2
        clipsToBounds = true
        backgroundColor = .systemGray
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
