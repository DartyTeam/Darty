//
//  ContactWithUsVC.swift
//  Darty
//
//  Created by Руслан Садыков on 02.08.2021.
//

import UIKit
import Lottie

final class ContactWithUsVC: UIViewController {

    // MARK: - UI Elements
    private let mailAnimationView = AnimationView(name: "SendMail")
    
    private let emailTextField: TextField = {
        let textField = TextField(color: .systemIndigo, placeholder: "Ваш email")
        textField.textContentType = .emailAddress
        return textField
    }()
    
    private let messageTextView: TextView = {
        let textView = TextView(placeholder: "Сообщение", isEditable: true, color: .systemIndigo)
        return textView
    }()
    
    private let sendButton: UIButton = {
        let button = UIButton(title: "Отправить")
        button.backgroundColor = .systemIndigo
        return button
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemIndigo
        setupViews()
        setupConstraints()
    }
    
    private func setupViews() {
        view.addSubview(emailTextField)
    }
    
    private func setupConstraints() {
        mailAnimationView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(32)
            make.left.right.equalToSuperview().inset(76)
        }
        
        emailTextField.snp.makeConstraints { make in
            make.top.equalTo(mailAnimationView.snp.bottom).offset(32)
            make.left.right.equalToSuperview().inset(44)
        }
        
        messageTextView.snp.makeConstraints { make in
            make.top.equalTo(emailTextField.snp.bottom).offset(32)
            make.left.right.equalToSuperview().inset(44)
        }
        
        sendButton.snp.makeConstraints { make in
            make.top.equalTo(messageTextView.snp.bottom).offset(44)
        }
    }
    
    // MARK: - Handlers
}

