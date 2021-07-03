//
//  NameSetupProfileVC.swift
//  Darty
//
//  Created by Руслан Садыков on 28.06.2021.
//

private enum Constants {
    static let textPlaceholder = "Text here..."
    static let textFont: UIFont? = .sfProText(ofSize: 24, weight: .medium)
}


import UIKit
import FirebaseAuth



final class NameSetupProfileVC: UIViewController {
    
    // MARK: - UI Elements
    private lazy var nextButton: UIButton = {
        let button = UIButton(title: "Далее 􀰑")
        button.backgroundColor = .systemBlue
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(nextButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var nameTextField: BottomLineTextField = {
        let textField = BottomLineTextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.placeholder = Constants.textPlaceholder
        textField.font = Constants.textFont
        textField.textAlignment = .center
        textField.delegate = self
        return textField
    }()
    
    // MARK: - Properties
    private let currentUser: User
    
    // MARK: - Lifecycle
    init(currentUser: User) {
        self.currentUser = currentUser
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setNavigationBar(withColor: .systemBlue, title: "Имя")
        setupViews()
        setupConstraints()
    }
    
    private func setupViews() {
        if let image = UIImage(named: "name.setup.background")?.withTintColor(.systemBlue.withAlphaComponent(0.5)) {
            addBackground(image)
        }
        
        view.backgroundColor = .systemBackground
        
        view.addSubview(nameTextField)
        view.addSubview(nextButton)
    }
    
    // MARK: - Handlers
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    @objc private func nextButtonTapped() {
        let aboutSetupProfileVC = AboutSetupProfileVC(currentUser: currentUser)
        navigationController?.pushViewController(aboutSetupProfileVC, animated: true)
    }
}

// MARK: - Setup constraints
extension NameSetupProfileVC {
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            nextButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            nextButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            nextButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -44),
            nextButton.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        NSLayoutConstraint.activate([
            nameTextField.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            nameTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 44),
            nameTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -44),
        ])
    }
}

// MARK: - UITextFieldDelegate
extension NameSetupProfileVC: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        nameTextField.select(true)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        nameTextField.select(false)
    }
}
