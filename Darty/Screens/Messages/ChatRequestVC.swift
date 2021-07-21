//
//  ChatRequestVC.swift
//  Darty
//
//  Created by Руслан Садыков on 07.07.2021.
//

import UIKit

final class ChatRequestVC: UIViewController {
    
    private let containerView = UIView()
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = .sfProDisplay(ofSize: 20, weight: .medium)
        return label
    }()
   
    private let ageLabel: UILabel = {
        let label = UILabel()
        label.font = .sfProDisplay(ofSize: 20, weight: .medium)
        return label
    }()
    
    private let aboutText: AboutInputText = {
        AboutInputText(isEditable: false)
    }()
    
    private let ratingLabel: UILabel = {
        let label = UILabel()
        label.font = .sfProDisplay(ofSize: 16, weight: .medium)
        return label
    }()
   
    private let interestsLabel: UILabel = {
        let label = UILabel()
        label.font = .sfProDisplay(ofSize: 16, weight: .medium)
        return label
    }()
    
    private let interestsList: UILabel = {
        let label = UILabel()
        label.font = .sfProDisplay(ofSize: 16, weight: .medium)
        return label
    }()

    private let infoLabel: UILabel = {
        let label = UILabel()
        label.text = "Пользователь хочет написать вам сообщение"
        return label
    }()
    
    private let acceptButton: UIButton = {
        let button = UIButton(title: "Принять")
        button.backgroundColor = .systemGreen
        return button
    }()
    
    private let denyButton: UIButton = {
        let button = UIButton(title: "Отклонить")
        button.backgroundColor = .systemRed
        return button
    }()
    
    weak var delegate: WaitingChatsNavigation?
    
    private var chat: ChatModel
    
    init(chat: ChatModel) {
        self.chat = chat
        nameLabel.text = chat.friendUsername
        imageView.sd_setImage(with: URL(string: chat.friendAvatarStringUrl), completed: nil)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        aboutText.textView.text = "Я люблю есть бананы и гулять по пальмам со своим другом страусом, которого зовут Джеки нечан, он нчееь забавный. АХаххахаххахаххахахаasfjkhaskjfhaskfjgasfkhjgasfasgfyuawykufawvfavfyawvf awyufvawfyauwvfuyaw,fkauywfawhfuyvawfwajuyffghjkl;kjhgfdagfdahgjsfdjhasfdajshkdfashjdfagshjdkfashjdfasjdhgfasgdhafsdghasfdghajsfdasjghdfasjghdfasghjdfasghjdfasghjdfasjghdfajsghdfasghjdfasghjdfagshjdfajsghdfajhgsdfagjhsdfghjasdfasghdfasfdafsfasdjfghfdagjsfgjhadsfgdasjgffgjadsfgjaddsfasdfsdfsdfasdfasdfasdfsadfadfsdfsdfsdfsdfasdfasdfasdfasfasdssdfsghjkl;lkjhgfdsdafghjkl;'lkjhgfdsadfghjkl;'lkjhgfd"
        view.backgroundColor = .systemGray
        customizeElements()
        setupConstraints()
        
        denyButton.addTarget(self, action: #selector(denyButtonTapped), for: .touchUpInside)
        acceptButton.addTarget(self, action: #selector(acceptButtonTapped), for: .touchUpInside)
    }
    
    @objc private func denyButtonTapped() {
        self.dismiss(animated: true) {
            self.delegate?.removeWaitingChat(chat: self.chat)
        }
    }
    
    @objc private func acceptButtonTapped() {
        self.dismiss(animated: true) {
            self.delegate?.changeToActive(chat: self.chat)
        }
    }
    
    private func customizeElements() {
        
        denyButton.layer.borderWidth = 1.2
        denyButton.layer.borderColor = #colorLiteral(red: 0.8352941176, green: 0.2, blue: 0.2, alpha: 1)
       
        containerView.backgroundColor = .systemGray
        containerView.layer.cornerRadius = 30
    }
}

// MARK: - Setup constraints
extension ChatRequestVC {
    
    private func setupConstraints() {
        
        let nameAgeStackView = UIStackView(arrangedSubviews: [nameLabel, ageLabel], axis: .horizontal, spacing: 8)
       
        let interestsStackView = UIStackView(arrangedSubviews: [interestsLabel, interestsList], axis: .vertical, spacing: 8)
                
        let buttonsStackView = UIStackView(arrangedSubviews: [acceptButton, denyButton], axis: .horizontal, spacing: 16)
        buttonsStackView.distribution = .fillEqually
        
        nameAgeStackView.translatesAutoresizingMaskIntoConstraints = false
        interestsStackView.translatesAutoresizingMaskIntoConstraints = false
        buttonsStackView.translatesAutoresizingMaskIntoConstraints = false
        containerView.translatesAutoresizingMaskIntoConstraints = false
        imageView.translatesAutoresizingMaskIntoConstraints = false
        aboutText.translatesAutoresizingMaskIntoConstraints = false
        ratingLabel.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(imageView)
        view.addSubview(containerView)
        
        containerView.addSubview(nameAgeStackView)
        containerView.addSubview(ratingLabel)
        containerView.addSubview(aboutText)
        containerView.addSubview(interestsStackView)
        containerView.addSubview(buttonsStackView)
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: view.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: containerView.topAnchor, constant: 30)
        ])
        
        NSLayoutConstraint.activate([
            containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            containerView.heightAnchor.constraint(equalToConstant: 420)
        ])

        NSLayoutConstraint.activate([
            ratingLabel.centerYAnchor.constraint(equalTo: nameAgeStackView.centerYAnchor),
            ratingLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -32)
        ])
        
        NSLayoutConstraint.activate([
            nameAgeStackView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 32),
            nameAgeStackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 32),
            nameAgeStackView.trailingAnchor.constraint(equalTo: ratingLabel.leadingAnchor, constant: -16)
        ])

        NSLayoutConstraint.activate([
            aboutText.topAnchor.constraint(equalTo: nameAgeStackView.bottomAnchor, constant: 8),
            aboutText.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            aboutText.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            aboutText.heightAnchor.constraint(equalToConstant: 128)
        ])

        NSLayoutConstraint.activate([
            interestsStackView.topAnchor.constraint(equalTo: aboutText.bottomAnchor, constant: 16),
            interestsStackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 32),
            interestsStackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -32)
        ])

        NSLayoutConstraint.activate([
            buttonsStackView.topAnchor.constraint(equalTo: interestsStackView.bottomAnchor, constant: 16),
            buttonsStackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 32),
            buttonsStackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -32),
            buttonsStackView.heightAnchor.constraint(equalToConstant: 54)
        ])
    }
}
