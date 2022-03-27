//
//  SetImageViewCell.swift
//  Darty
//
//  Created by Руслан Садыков on 16.07.2021.
//

import UIKit

final class SetImageViewCell: UICollectionViewCell {
        
    // MARK: - UI Elements
    let deleteButton: UIButton = {
        let button = UIButton(type: .system)
        let configIcon = UIImage.SymbolConfiguration(font: UIFont.systemFont(ofSize: 16, weight: .medium))
        let trashIcon = UIImage(systemName: "trash", withConfiguration: configIcon)?.withTintColor(.systemRed, renderingMode: .alwaysOriginal)
        button.setImage(trashIcon, for: .normal)
        button.layer.cornerRadius = 22
        button.clipsToBounds = true
        button.addBlurEffect()
        return button
    }()
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()
    
    // MARK - Lifecycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupCell(image: UIImage, shape: ShapeImageView, color: UIColor) {
        imageView.image = image
        
        if shape == .rect {
            imageView.snp.remakeConstraints { remake in
                remake.edges.equalToSuperview()
            }
            
            imageView.layer.cornerRadius = 20
        }
        
        imageView.layer.borderColor = color.withAlphaComponent(0.5).cgColor
    }
    
    private func setupViews() {
        contentView.addSubview(imageView)
        contentView.addSubview(deleteButton)
    }
    
    private func setupConstraints() {
        imageView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(self.frame.size.width)
            make.centerY.equalToSuperview()
        }

        imageView.layoutIfNeeded()
        imageView.layer.cornerRadius = imageView.frame.size.width / 2
        imageView.clipsToBounds = true
        imageView.layer.borderWidth = 3.5
        imageView.layer.borderColor = UIColor.systemBlue.withAlphaComponent(0.5).cgColor
        
        deleteButton.snp.makeConstraints { make in
            make.size.equalTo(44)
            make.centerX.equalToSuperview()
            make.bottom.equalTo(imageView.snp.bottom).offset(-32)
        }
    }
}
