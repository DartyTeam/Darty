//
//  AboutSetupProfileVC.swift
//  Darty
//
//  Created by Руслан Садыков on 02.07.2021.
//

import UIKit
import FirebaseAuth

final class AboutSetupProfileVC: UIViewController {
    
    // MARK: - UI Elements
    private lazy var nextButton: UIButton = {
        let button = UIButton(title: "Далее 􀰑", color: .blue)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(nextButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private let aboutTitleLabel: UILabel = {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Text here about you..."
        label.font = .sfProText(ofSize: 26, weight: .semibold)
        label.isUserInteractionEnabled = true
        return label
    }()
    
    private lazy var aboutTextView: UITextView = {
        let textView = UITextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.font = .sfProText(ofSize: 26, weight: .semibold)
        textView.delegate = self
        textView.showsVerticalScrollIndicator = false
        textView.backgroundColor = .clear
        textView.isUserInteractionEnabled = false
        return textView
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
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(aboutTitleAction))
        aboutTitleLabel.addGestureRecognizer(tapGesture)
        
        setNavigationBar(withColor: .systemBlue, title: "О вас")
        setupViews()
        setupConstraints()
    }
    
    private func setupViews() {
        if let image = UIImage(named: "about.setup.background")?.withTintColor(.systemBlue.withAlphaComponent(0.75)) {
            addBackground(image)
        }
                
        view.backgroundColor = .systemBackground
        
        view.addSubview(aboutTextView)
        view.addSubview(aboutTitleLabel)
        view.addSubview(nextButton)
    }
    
    // MARK: - Handlers
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    @objc private func nextButtonTapped() {
        let aboutSetupProfileVC = SexSetupProfileVC(currentUser: currentUser)
        navigationController?.pushViewController(aboutSetupProfileVC, animated: true)
    }
    
    @objc private func aboutTitleAction() {
        aboutTitleLabel.isHidden = true
        aboutTextView.becomeFirstResponder()
        aboutTextView.centerVertically()
        aboutTextView.text = ""
        aboutTextView.isUserInteractionEnabled = true
    }
}

// MARK: - Setup constraints
extension AboutSetupProfileVC {
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            nextButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            nextButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            nextButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -44),
            nextButton.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        NSLayoutConstraint.activate([
            aboutTextView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 44),
            aboutTextView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -44),
            aboutTextView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 44),
            aboutTextView.bottomAnchor.constraint(equalTo: nextButton.topAnchor, constant: -44),
        ])
        
        NSLayoutConstraint.activate([
            aboutTitleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 44),
            aboutTitleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -44),
            aboutTitleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 44),
            aboutTitleLabel.bottomAnchor.constraint(equalTo: nextButton.topAnchor, constant: -44),
        ])
    }
}

// MARK: - UITextViewDelegate
extension AboutSetupProfileVC: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        textView.centerVertically()
     }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            aboutTitleLabel.isHidden = false
            aboutTextView.isUserInteractionEnabled = false
        }
    }
}
