//
//  PartyImageCell.swift
//  Darty
//
//  Created by Руслан Садыков on 21.07.2021.
//

import UIKit
import SDWebImage

final class PartyImageCell: UICollectionViewCell {
    
    private enum Constants {
        static let imageWidth: CGFloat = 118
        static let imageHeight: CGFloat = 96
    }
    
    // MARK: - UI Elements
    private let partyImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.cornerRadius = 10
        imageView.layer.cornerCurve = .continuous
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.backgroundColor = .systemGray
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.cornerRadius = 10
        layer.shadowColor = UIColor(red: 0.769, green: 0.769, blue: 0.769, alpha: 0.5).cgColor
        layer.shadowOpacity = 1
        layer.shadowRadius = 5
        layer.shadowOffset = CGSize(width: 0, height: 0)
        
        setupConstraints()
    }
    
    func configure(with imageUrl: URL) {
        partyImageView.sd_setImage(with: imageUrl, completed: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Setup constraints
extension PartyImageCell {
    
    private func setupConstraints() {
        addSubview(partyImageView)
        partyImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalTo(Constants.imageWidth)
            make.height.equalTo(Constants.imageHeight)
        }
    }
}
