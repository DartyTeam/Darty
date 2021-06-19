//
//  LoginVC.swift
//  Darty
//
//  Created by Руслан Садыков on 19.06.2021.
//

import UIKit

class LoginVC: UIViewController {
    
    // MARK: - UI Elements
    let testButton: UIButton = {
        let button = UIButton(title: "Старт", color: .purple)
        button.addTarget(self, action: #selector(test), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white
        
        view.addSubview(testButton)
        
        testButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            testButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            testButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            testButton.widthAnchor.constraint(equalToConstant: 300),
            testButton.heightAnchor.constraint(equalToConstant: 44),
        ])
        
        setupViews()
        setupConstraints()
    }
    
    @objc private func test() {
        let tabBar = TabBarController()
        navigationController?.pushViewController(tabBar, animated: false)
    }
    
    private func setupViews() {
        
    }
    
    private func setupConstraints() {
        
    }
}
