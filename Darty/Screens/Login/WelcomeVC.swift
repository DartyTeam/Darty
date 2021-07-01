//
//  WelcomeVC.swift
//  Darty
//
//  Created by Руслан Садыков on 29.06.2021.
//

import UIKit

final class WelcomeVC: UIViewController {
    
    // MARK: - Elements sizes
    private var leftViewSize: CGFloat = 44
    
    // MARK: - UI Elements
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        
        let attrs1 = [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 22), NSAttributedString.Key.foregroundColor : UIColor.black]

        let attrs2 = [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 22), NSAttributedString.Key.foregroundColor : UIColor.systemPurple]

        let attributedString1 = NSMutableAttributedString(string:"Что можно делать в", attributes:attrs1)

        let attributedString2 = NSMutableAttributedString(string:" Darty?", attributes:attrs2)

        attributedString1.append(attributedString2)
        label.attributedText = attributedString1
        
        return label
    }()
    
    private lazy var partyView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = leftViewSize / 2
        view.backgroundColor = .systemOrange
        
        let fireIcon = UIImageView(image: UIImage(systemName: "fire"))
        view.addSubview(fireIcon)
        fireIcon.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            fireIcon.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            fireIcon.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
        
        return view
    }()
    
    // MARK: - Variables
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        setupConstraints()
    }

    private func setupViews() {
        view.backgroundColor = .white
        
        view.addSubview(titleLabel)
        view.addSubview(partyView)
    }
    
    private func setupConstraints() {
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 64),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32),
        ])
        
    }
}
