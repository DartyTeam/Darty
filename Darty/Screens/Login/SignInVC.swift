//
//  SignInVC.swift
//  Darty
//
//  Created by Руслан Садыков on 04.07.2021.
//

import UIKit
import FirebaseAuth

private enum Constants {
    static let socialButtonSize: CGFloat = 50
    static let infoTextFont: UIFont? = .sfProDisplay(ofSize: 10, weight: .regular)
    static let textFieldFont: UIFont? = .sfProText(ofSize: 25, weight: .medium)
}

final class SignInVC: UIViewController {
    
    // MARK: - UI Elements
    private let dartyLogo: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "darty.logo"))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let acceptButton: UIButton = {
        let button = UIButton(title: "Далее 􀰑")
        button.backgroundColor = .systemPurple
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(acceptAction), for: .touchUpInside)
        return button
    }()
    
    private let warningLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = Constants.infoTextFont
        label.text = "На ваш номер будет отправлено смс с кодом подтверждения, которое будет необходимо ввести на следующем этапе"
        label.textColor = .systemGray
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()
    
    private lazy var phoneTextField: BottomLineTextField = {
        let textField = BottomLineTextField(color: .systemPurple)
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.font = Constants.textFieldFont
        textField.tintColor = .systemPurple
        textField.delegate = self
        textField.placeholder = "+X (XXX) XXX XX XX"
        textField.textColor = .systemPurple
        textField.keyboardType = .numberPad
        return textField
    }()
    
    private let containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
   
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupConstraints()
    }
    
    private func setupViews() {
       
        view.backgroundColor = .systemBackground
        
        setNavigationBar(withColor: .systemPurple, title: "Введите номер")
        view.addSubview(acceptButton)
        view.addSubview(dartyLogo)
        view.addSubview(warningLabel)
        view.addSubview(containerView)
        containerView.addSubview(phoneTextField)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            acceptButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            acceptButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            acceptButton.heightAnchor.constraint(equalToConstant: 50),
            acceptButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -44)
        ])
        
        NSLayoutConstraint.activate([
            dartyLogo.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 112),
            dartyLogo.centerXAnchor.constraint(equalTo: view.centerXAnchor),
        ])
        
        NSLayoutConstraint.activate([
            warningLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            warningLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            warningLabel.bottomAnchor.constraint(equalTo: acceptButton.topAnchor, constant: -33),
        ])
        
        NSLayoutConstraint.activate([
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            containerView.topAnchor.constraint(lessThanOrEqualTo: dartyLogo.bottomAnchor),
            containerView.bottomAnchor.constraint(greaterThanOrEqualTo: warningLabel.topAnchor)
        ])
        
        NSLayoutConstraint.activate([
            phoneTextField.widthAnchor.constraint(equalToConstant: 256),
            phoneTextField.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            phoneTextField.centerXAnchor.constraint(equalTo: containerView.centerXAnchor)
        ])
    }
    
    // MARK: - Handlers
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    @objc private func acceptAction() {
        
    }
    
    func format(with mask: String, phone: String) -> String {
        let numbers = phone.replacingOccurrences(of: "[^0-9]", with: "", options: .regularExpression)
        var result = ""
        var index = numbers.startIndex // numbers iterator

        // iterate over the mask characters until the iterator of numbers ends
        for ch in mask where index < numbers.endIndex {
            if ch == "X" {
                // mask requires a number in this place, so take the next one
                result.append(numbers[index])

                // move numbers iterator to the next index
                index = numbers.index(after: index)

            } else {
                result.append(ch) // just append a mask character
            }
        }
        return result
    }
}

extension SignInVC: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let text = textField.text else { return false }
        let newString = (text as NSString).replacingCharacters(in: range, with: string)
        textField.text = format(with: "+X (XXX) XXX XX XX", phone: newString)
        if textField.text?.digits.count == 11 {
            resignFirstResponder()
        }
        return false
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        phoneTextField.select(true)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        phoneTextField.select(false)
    }
}


