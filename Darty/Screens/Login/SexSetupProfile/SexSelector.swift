//
//  SexSelector.swift
//  Darty
//
//  Created by Руслан Садыков on 03.07.2021.
//

protocol SexSelectorDelegate {
    func sexSelected(_ sex: Sex)
    func sexDeselected(_ sex: Sex)
}

enum Sex: String {
    case man = "man"
    case woman = "woman"
    case another = "another"
}

import UIKit

private enum Constants {
    static let textFont: UIFont? = .sfProDisplay(ofSize: 18, weight: .semibold)
}

class SexSelector: UIView {
    
    // MARK: UI Elements
    private lazy var backView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = size / 2
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.font = Constants.textFont
        return label
    }()
    
    private let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var selectedView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = size / 2
        view.backgroundColor = color.withAlphaComponent(0.5)
        
        let boldConfig = UIImage.SymbolConfiguration(font: UIFont.systemFont(ofSize: 28, weight: .bold))
        let checkMarkIcon = UIImageView(image: UIImage(systemName: "checkmark", withConfiguration: boldConfig)?.withTintColor(.white, renderingMode: .alwaysOriginal))
        checkMarkIcon.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(checkMarkIcon)
        
        NSLayoutConstraint.activate([
            checkMarkIcon.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            checkMarkIcon.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
        
        view.alpha = 0
        return view
    }()
    
    // MARK: - Properties
    private let size: CGFloat!
    private let color: UIColor!
    private let delegate: SexSelectorDelegate!
    let sex: Sex!
    var isSelected: Bool = false {
        didSet {
            if self.isSelected {
                UIView.animate(withDuration: 0.3) {
                    self.selectedView.alpha = 1
                }
                self.delegate.sexSelected(sex)
            } else {
                UIView.animate(withDuration: 0.3) {
                    self.selectedView.alpha = 0
                }
                self.delegate.sexDeselected(sex)
            }
        }
    }
    
    // MARK: - Lifecycle
    init(title: String, iconImage: UIImage?, backgroundColor: UIColor, size: CGFloat, delegate: SexSelectorDelegate, sex: Sex) {
        self.size = size
        self.color = backgroundColor
        self.delegate = delegate
        self.sex = sex
        super.init(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
 
        backView.backgroundColor = backgroundColor
        iconImageView.image = iconImage
        titleLabel.text = title
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tappedAction))
        addGestureRecognizer(tapGesture)
        
        setupViews()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        addSubview(backView)
        backView.addSubview(iconImageView)
        backView.addSubview(selectedView)
        addSubview(titleLabel)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            backView.heightAnchor.constraint(equalToConstant: size),
            backView.widthAnchor.constraint(equalToConstant: size),
            backView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            backView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            backView.topAnchor.constraint(equalTo: self.topAnchor),
        ])
        
        NSLayoutConstraint.activate([
            iconImageView.topAnchor.constraint(equalTo: backView.topAnchor, constant: 21),
            iconImageView.leadingAnchor.constraint(equalTo: backView.leadingAnchor, constant: 21),
            iconImageView.trailingAnchor.constraint(equalTo: backView.trailingAnchor, constant: -21),
            iconImageView.bottomAnchor.constraint(equalTo: backView.bottomAnchor, constant: -21),
        ])
        
        NSLayoutConstraint.activate([
            selectedView.topAnchor.constraint(equalTo: backView.topAnchor),
            selectedView.leadingAnchor.constraint(equalTo: backView.leadingAnchor),
            selectedView.trailingAnchor.constraint(equalTo: backView.trailingAnchor),
            selectedView.bottomAnchor.constraint(equalTo: backView.bottomAnchor),
        ])
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: backView.bottomAnchor, constant: 8),
            titleLabel.centerXAnchor.constraint(equalTo: backView.centerXAnchor)
        ])
        
        NSLayoutConstraint.activate([
            self.bottomAnchor.constraint(equalTo: titleLabel.bottomAnchor)
        ])
    }
    
    // MARK: - Handlers
    @objc private func tappedAction() {
        isSelected.toggle()
        showAnimation {
            
        }
    }
}
