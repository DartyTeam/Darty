//
//  MessageForRequestVC.swift
//  Darty
//
//  Created by Руслан Садыков on 23.07.2021.
//

import UIKit

protocol MessageForRequestsDelegate {
    func messageDidEnter(_ message: String)
}

final class MessageForRequestVC: UIViewController {
    
    private enum Constants {
        static let titleFont: UIFont? = .sfProDisplay(ofSize: 20, weight: .medium)
        static let titleText = "Сообщение для организатора вечеринки"
        static let topLineHeight: CGFloat = 6
    }
    
    // MARK: - UI Elements
    private lazy var topLineView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = Constants.topLineHeight / 2
        return view
    }()
    
    private let closeButton: UIButton = {
        let button = UIButton(type: .close)
        button.tintColor = Colors.Elements.element
        button.addTarget(self, action: #selector(closeAction), for: .touchDown)
        return button
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = Constants.titleText
        label.font = Constants.titleFont
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var messageTextField: MessageTextField = {
        let messageTextField = MessageTextField()
        messageTextField.sendButton.addTarget(self, action: #selector(messageAction), for: .touchUpInside)
        messageTextField.delegate = self
        return messageTextField
    }()
    
    // MARK: - Properties
    private let delegate: MessageForRequestsDelegate
    
    // MARK: - Lifecycle
    init(delegate: MessageForRequestsDelegate) {
        self.delegate = delegate
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupConstraints()
    }
    
    private func setupViews() {
        view.backgroundColor = .clear
        view.layer.cornerRadius = 30
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        view.clipsToBounds = true
        
        let blurEffect = UIBlurEffect(style: .systemUltraThinMaterial)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = view.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        view.insertSubview(blurEffectView, at: 0)
        
        blurEffectView.contentView.addSubview(closeButton)
        blurEffectView.contentView.addSubview(topLineView)
        blurEffectView.contentView.addSubview(titleLabel)
        blurEffectView.contentView.addSubview(messageTextField)
    }
    
    private func setupConstraints() {
        
        topLineView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(12)
            make.width.equalTo(64)
            make.centerX.equalToSuperview()
            make.height.equalTo(6)
        }
        
        closeButton.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-12)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(32)
            make.left.equalToSuperview().inset(32)
            make.right.equalToSuperview().inset(32)
        }
        
        messageTextField.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(16)
            make.left.right.equalToSuperview().inset(32)
            make.height.equalTo(MessageTextField.defaultHeight)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-32)
        }
    }
    
    // MARK: - Handlers
    @objc private func closeAction() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc private func messageAction() {
        delegate.messageDidEnter(messageTextField.text ?? "")
        dismiss(animated: true, completion: nil)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
}

extension MessageForRequestVC: UITextFieldDelegate {
    #warning("Возможно тут стоит добавить resign first responder")
}
