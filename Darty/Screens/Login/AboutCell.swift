//
//  AboutCell.swift
//  Darty
//
//  Created by Руслан Садыков on 01.07.2021.
//

import UIKit

private enum Constants {
    static let iconViewSize: CGFloat = 44.0
    static let bottomOffset: CGFloat = 32
    static let horizontalInsets: CGFloat = 32
}

final class AboutCell: UITableViewCell {
    
    // MARK: - UI Elements    
    private lazy var backIconView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = Constants.iconViewSize / 2
        view.backgroundColor = .systemOrange
        return view
    }()
    
    private let iconImage: UIImageView = {
        let imageView = UIImageView(image: UIImage(systemName: "flame")?.withTintColor(.white, renderingMode: .alwaysOriginal))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .sfProDisplay(ofSize: 14, weight: .semibold)
        label.numberOfLines = 0
        label.text = "Создавать и искать вечеринки"
        return label
    }()
    
    let subtitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .sfProDisplay(ofSize: 12, weight: .regular)
        label.numberOfLines = 0
        label.textColor = .black.withAlphaComponent(0.4)
        label.text = "Вписка или танцевальная вечеринка? А может, домашний хакатон? Все это уже в твоих руках"
        return label
    }()
   
    // MARK: - Lifecycle
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupViews()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupCell(backIconColor: UIColor, iconImage: UIImage?, title: String, subtitle: String) {
        
        titleLabel.text = title
        subtitleLabel.text = subtitle
        backIconView.backgroundColor = backIconColor
        self.iconImage.image = iconImage
    }
    
    // MARK: - Setup views
    private func setupViews() {
        backgroundColor = .clear
        
        backIconView.addSubview(iconImage)
        addSubview(backIconView)
        addSubview(titleLabel)
        addSubview(subtitleLabel)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            iconImage.centerYAnchor.constraint(equalTo: backIconView.centerYAnchor),
            iconImage.centerXAnchor.constraint(equalTo: backIconView.centerXAnchor),
        ])
        
        NSLayoutConstraint.activate([
            backIconView.heightAnchor.constraint(equalToConstant: Constants.iconViewSize),
            backIconView.widthAnchor.constraint(equalToConstant: Constants.iconViewSize),
            backIconView.centerYAnchor.constraint(equalTo: self.centerYAnchor, constant: -Constants.bottomOffset / 2),
            backIconView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: Constants.horizontalInsets)
        ])
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: self.topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: backIconView.trailingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -Constants.horizontalInsets)
        ])
        
        NSLayoutConstraint.activate([
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            subtitleLabel.leadingAnchor.constraint(equalTo: backIconView.trailingAnchor, constant: 16),
            subtitleLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -Constants.horizontalInsets)
        ])
        
        NSLayoutConstraint.activate([
            self.bottomAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: Constants.bottomOffset),
        ])
    }
}
