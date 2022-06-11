//
//  SetAddImagesViewCell.swift
//  Darty
//
//  Created by Руслан Садыков on 16.07.2021.
//

import UIKit
import PhotosUI

final class SetAddImagesViewCell: UICollectionViewCell {
            
    // MARK: - UI Elements
    private lazy var setImageView: SetImageView = {
        let setImageView = SetImageView(delegate: nil, color: .systemBlue)
        return setImageView
    }()

    private var imagePicker: PHPickerViewController!
    
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
    
    func setupCell(delegate: SetImageDelegate, shape: ShapeImageView, color: UIColor, phpicker: PHPickerViewController) {
        setImageView.setup(phpicker: phpicker)
        setImageView.delegate = delegate
        setImageView.color = color
        self.color = color

        if shape == .rect {
            setImageView.snp.remakeConstraints { remake in
                remake.leading.trailing.equalToSuperview()
                remake.top.bottom.equalToSuperview()
            }
            
            setImageView.layer.cornerRadius = 20
            setImageView.layer.cornerCurve = .continuous
        }
        
        setImageView.layer.borderColor = color.withAlphaComponent(0.5).cgColor
    }
    
    private func setupViews() {
        addSubview(setImageView)
    }
    
    private func setupConstraints() {
        setImageView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(self.frame.size.width)
            make.centerY.equalToSuperview()
        }

        setImageView.layoutIfNeeded()
        setImageView.layer.cornerRadius = setImageView.frame.size.width / 2
        setImageView.clipsToBounds = true
        setImageView.layer.borderWidth = 3.5
        setImageView.layer.borderColor = UIColor.systemBlue.withAlphaComponent(0.5).cgColor
    }
}
