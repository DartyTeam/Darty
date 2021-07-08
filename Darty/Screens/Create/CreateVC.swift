//
//  CreateVC.swift
//  Darty
//
//  Created by Руслан Садыков on 19.06.2021.
//

import UIKit
import FirebaseAuth

final class CreateVC: UIViewController {
    
    // MARK: - UI Elements
    private enum Constants {
        static let textPlaceholder = "Наименование"
        static let textFont: UIFont? = .sfProText(ofSize: 12, weight: .regular)
    }
    
    // MARK: - UI Elements
    private lazy var nextButton: UIButton = {
        let button = UIButton(title: "Далее 􀰑")
        button.backgroundColor = .systemPurple
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(nextButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var nameTextField: UITextField = {
        let textField = BottomLineTextField(color: .systemBlue)
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.placeholder = Constants.textPlaceholder
        textField.font = Constants.textFont
        textField.textAlignment = .center
        textField.delegate = self
        textField.returnKeyType = .next
        return textField
    }()
    
    // MARK: - Properties
    private let currentUser: UserModel
    private var party: PartyModel?
    
    // MARK: - Lifecycle
    init(currentUser: UserModel) {
        self.currentUser = currentUser
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setNavigationBar(withColor: .systemPurple, title: "Создание вечеринки")
        setupViews()
        setupConstraints()
    }
    
    private func setupViews() {
        view.backgroundColor = .systemBackground
        view.addSubview(nextButton)
        view.addSubview(nameTextField)
    }
    
    // MARK: - Handlers
    @objc private func nextButtonTapped() {

    }
}

// MARK: - Setup constraints
extension CreateVC {
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            nextButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            nextButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            nextButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -44),
            nextButton.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        NSLayoutConstraint.activate([
            nameTextField.bottomAnchor.constraint(equalTo: nextButton.topAnchor, constant: -32),
            nameTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            nameTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }
}

extension CreateVC: UITextFieldDelegate {
    
}

