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
        let button = UIButton(title: "Sign In", color: .blue)
        button.addTarget(self, action: #selector(test), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        setupConstraints()
    }
    
    @objc private func test() {
        let tabBar = TabBarController()
        navigationController?.pushViewController(tabBar, animated: false)
    }
    
    private func addBackground() {
        // screen width and height:
        let width = UIScreen.main.bounds.size.width
        let height = UIScreen.main.bounds.size.height
        
        let imageViewBackground = UIImageView(frame: CGRect(x: 0, y: 0, width: width, height: height))
        imageViewBackground.image = UIImage(named: "login.background")
        
        // you can change the content mode:
        imageViewBackground.contentMode = UIView.ContentMode.scaleAspectFill
        
        view.addSubview(imageViewBackground)
        view.sendSubviewToBack(imageViewBackground)
    }
    
    private func setupViews() {
        addBackground()
        
        view.addSubview(testButton)
    }
    
    private func setupConstraints() {
        
        testButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            testButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            testButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            testButton.widthAnchor.constraint(equalToConstant: 300),
            testButton.heightAnchor.constraint(equalToConstant: 44),
        ])
    }
}
