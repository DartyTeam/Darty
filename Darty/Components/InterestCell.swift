//
//  InterestCell.swift
//  Darty
//
//  Created by Руслан Садыков on 05.07.2021.
//

import UIKit

final class LeftAlignedCollectionViewFlowLayout: UICollectionViewFlowLayout {

    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        let attributes = super.layoutAttributesForElements(in: rect)

        var leftMargin = sectionInset.left
        var maxY: CGFloat = -1.0
        attributes?.forEach { layoutAttribute in
            guard layoutAttribute.representedElementCategory == .cell else {
                return
            }
            
            if layoutAttribute.frame.origin.y >= maxY {
                leftMargin = sectionInset.left
            }

            layoutAttribute.frame.origin.x = leftMargin

            leftMargin += layoutAttribute.frame.width + minimumInteritemSpacing
            maxY = max(layoutAttribute.frame.maxY , maxY)
        }

        return attributes
    }
}

final class InterestCell: UICollectionViewCell {

    // MARK: - Constants
    private enum Constants {
        static let font = UIFont.sfCompactDisplay(ofSize: 16, weight: .medium)
        static let textColor = UIColor.black.withAlphaComponent(0.5)
        static let selectedColor: UIColor = .systemPurple.withAlphaComponent(0.5)
        static let deselectedColor: UIColor = #colorLiteral(red: 0.768627451, green: 0.768627451, blue: 0.768627451, alpha: 0.25)
    }

    // MARK: - UI Elements
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = Constants.font
//        label.textColor = Constants.textColor
        return label
    }()

    private let emojiIcon: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = Constants.font
        return label
    }()

    // MARK: - Properties
    override var isSelected: Bool {
        didSet {
            backgroundColor = isSelected ? Constants.selectedColor : Constants.deselectedColor
        }
    }

    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        setupConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle
    override func layoutSubviews() {
        super.layoutSubviews()
        self.layer.cornerRadius = self.layer.bounds.height / 2
    }

    // MARK: - Setup
    func setupCell(title: String, emoji: String) {
        titleLabel.text = title
        emojiIcon.text = emoji
    }

    private func setupViews() {
        self.backgroundColor = Constants.deselectedColor
        addSubview(emojiIcon)
        addSubview(titleLabel)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            emojiIcon.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            emojiIcon.centerYAnchor.constraint(equalTo: centerYAnchor),
        ])
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 6),
            titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -6),
            titleLabel.leadingAnchor.constraint(equalTo: emojiIcon.trailingAnchor, constant: 8),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
        ])
    }
}
