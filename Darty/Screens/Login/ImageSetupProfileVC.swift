//
//  ImageSetupProfileVC.swift
//  Darty
//
//  Created by Руслан Садыков on 02.07.2021.
//

import UIKit
import FirebaseAuth

final class ImageSetupProfileVC: UIViewController {
    
    // MARK: - UI Elements
    private lazy var nextButton: UIButton = {
        let button = UIButton(title: "Далее 􀰑", color: .blue)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(nextButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var blurredEffectView: BlurEffectView = {
        let blurredEffectView = BlurEffectView()
        blurredEffectView.translatesAutoresizingMaskIntoConstraints = false
        blurredEffectView.layer.cornerRadius = 40
        blurredEffectView.clipsToBounds = true
        blurredEffectView.layer.borderWidth = 3.5
        blurredEffectView.layer.borderColor = UIColor.systemBlue.cgColor
        return blurredEffectView
    }()
    
    // MARK: - Properties
    private let currentUser: User
    
    // MARK: - Lifecycle
    init(currentUser: User) {
        self.currentUser = currentUser
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        setNavigationBar(withColor: .systemBlue, title: "Изображение")
        setupViews()
        setupConstraints()
    }
    
    private func setupViews() {
        if let image = UIImage(named: "image.setup.background")?.withTintColor(.systemBlue.withAlphaComponent(0.75)) {
            addBackground(image)
        }
        
        view.backgroundColor = .systemBackground
        
        view.addSubview(blurredEffectView)
        view.addSubview(nextButton)
    }
    
    // MARK: - Handlers
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    @objc private func nextButtonTapped() {
        
        
    }
}

// MARK: - Setup constraints
extension ImageSetupProfileVC {
    
    private func setupConstraints() {
                
        NSLayoutConstraint.activate([
            nextButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            nextButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            nextButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -44),
            nextButton.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        NSLayoutConstraint.activate([
            blurredEffectView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            blurredEffectView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            blurredEffectView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 44),
            blurredEffectView.bottomAnchor.constraint(equalTo: nextButton.topAnchor, constant: -44)
        ])
    }
}

// MARK: - UITextFieldDelegate
extension ImageSetupProfileVC: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
