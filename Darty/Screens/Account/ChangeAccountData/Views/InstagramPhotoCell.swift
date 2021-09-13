//
//  InstagramPhotoCell.swift
//  Darty
//
//  Created by Руслан Садыков on 11.09.2021.
//

import UIKit
import SDWebImage

final class InstagramPhotoCell: UICollectionViewCell {
    
    private enum Constants {
        static let imageSize: CGFloat = 64
    }
    
    // MARK: - UI Elements
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.cornerRadius = 10
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
        imageView.sd_setImage(with: imageUrl, completed: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Setup constraints
extension InstagramPhotoCell {
    
    private func setupConstraints() {
        addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.size.equalTo(Constants.imageSize)
        }
    }
}
