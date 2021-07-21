//
//  SetAddImagesViewCell.swift
//  Darty
//
//  Created by Руслан Садыков on 16.07.2021.
//

import UIKit

final class SetAddImagesViewCell: UICollectionViewCell {
            
    // MARK: - UI Elements
    private lazy var setImageView: SetImageView = {
        let setImageView = SetImageView(delegate: nil, maxPhotos: 1, color: .systemBlue)
        return setImageView
    }()
    
    // MARK: - Properties
    private var color: UIColor = .systemBlue {
        didSet {
            setImageView.layer.borderColor = color.withAlphaComponent(0.5).cgColor
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupCell(delegate: SetImageDelegate, maxPhotos: Int, shape: ShapeImageView, color: UIColor) {
        
        setImageView.delegate = delegate
        setImageView.maxPhotos = maxPhotos
        setImageView.color = color
        self.color = color

        if shape == .round {
            setImageView.snp.remakeConstraints { remake in
                remake.leading.trailing.equalToSuperview().inset(20)
                remake.height.equalTo(setImageView.frame.size.width - 40)
                remake.centerY.equalToSuperview()
            }

            setImageView.layoutIfNeeded()
            setImageView.layer.cornerRadius = setImageView.frame.size.width / 2
        }
    }
    
    private func setupViews() {
        addSubview(setImageView)
    }
    
    private func setupConstraints() {
        setImageView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(20)
            make.top.bottom.equalToSuperview()
        }

        setImageView.layoutIfNeeded()
        setImageView.layer.cornerRadius = 20
        
        setImageView.clipsToBounds = true
        setImageView.layer.borderWidth = 3.5
        setImageView.layer.borderColor = color.withAlphaComponent(0.5).cgColor
    }
}
