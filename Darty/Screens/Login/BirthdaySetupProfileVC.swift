//
//  BirthdaySetupProfileVC.swift
//  Darty
//
//  Created by Руслан Садыков on 02.07.2021.
//

import UIKit
import FirebaseAuth

final class BirthdaySetupProfileVC: UIViewController {
    
    private lazy var nextButton: UIButton = {
        let button = UIButton(title: "Далее 􀰑")
        button.backgroundColor = .systemBlue
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(nextButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private let datePicker: UIDatePicker = {
        let datePicker = UIDatePicker()
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        datePicker.datePickerMode = .date
        if #available(iOS 13.4, *) {
            datePicker.preferredDatePickerStyle = .wheels
        } else {
            // Fallback on earlier versions
        }
        datePicker.maximumDate = Date()
        
        return datePicker
    }()

    private lazy var blurredEffectView: BlurEffectView = {
        let blurredEffectView = BlurEffectView()
        blurredEffectView.translatesAutoresizingMaskIntoConstraints = false
        blurredEffectView.layer.cornerRadius = 40
        blurredEffectView.clipsToBounds = true
        blurredEffectView.layer.borderWidth = 3.5
        blurredEffectView.layer.borderColor = UIColor.systemBlue.withAlphaComponent(0.5).cgColor
        return blurredEffectView
    }()

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
        setNavigationBar(withColor: .systemBlue, title: "День рождения")
        setupViews()
        setupConstraints()
    }
    
    private func setupViews() {
        if let image = UIImage(named: "birthday.setup.background")?.withTintColor(.systemBlue.withAlphaComponent(0.75)) {
            addBackground(image)
        }
        
        view.backgroundColor = .systemBackground
        
        view.addSubview(blurredEffectView)
        blurredEffectView.contentView.addSubview(datePicker)
        view.addSubview(nextButton)
    }
    
    // MARK: - Handlers
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    @objc private func nextButtonTapped() {
        let aboutSetupProfileVC = ImageSetupProfileVC(currentUser: currentUser)
        navigationController?.pushViewController(aboutSetupProfileVC, animated: true)
    }
}

// MARK: - Setup constraints
extension BirthdaySetupProfileVC {
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            nextButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            nextButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            nextButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -44),
            nextButton.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        NSLayoutConstraint.activate([
            blurredEffectView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            blurredEffectView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            blurredEffectView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            blurredEffectView.heightAnchor.constraint(equalToConstant: UIScreen.main.bounds.height / 2)
        ])
    
        NSLayoutConstraint.activate([
            datePicker.centerYAnchor.constraint(equalTo: blurredEffectView.centerYAnchor),
            datePicker.leadingAnchor.constraint(equalTo: blurredEffectView.leadingAnchor),
            datePicker.trailingAnchor.constraint(equalTo: blurredEffectView.trailingAnchor),
            datePicker.heightAnchor.constraint(equalToConstant: UIScreen.main.bounds.height / 2)
        ])
    }
}
