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
        let button = UIButton(title: "Далее 􀰑")
        button.backgroundColor = .systemBlue
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(nextButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var setImageView: SetImageView = {
        let setImageView = SetImageView(delegate: self)
        setImageView.translatesAutoresizingMaskIntoConstraints = false
        return setImageView
    }()
    
    // MARK: - Properties
    private let currentUser: User
    private var setuppedUser: SetuppedUser
    
    // MARK: - Lifecycle
    init(currentUser: User, setuppedUser: SetuppedUser) {
        self.currentUser = currentUser
        self.setuppedUser = setuppedUser
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
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
        
        view.addSubview(setImageView)
        view.addSubview(nextButton)
    }
    
    // MARK: - Handlers
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    @objc private func nextButtonTapped() {
        guard let userimage = setImageView.image else {
            showAlert(title: "Выберите изображение", message: "")
            return
        }
        setuppedUser.image = userimage
        let interestsSetupProfileVC = InterestsSetupProfileVC(currentUser: currentUser, setupedUser: setuppedUser)
        navigationController?.pushViewController(interestsSetupProfileVC, animated: true)
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
            setImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            setImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            setImageView.heightAnchor.constraint(equalToConstant: setImageView.frame.size.width - 40),
            setImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])

        #warning("Хотелось бы это всунуть в сам класс SetImageView")
        setImageView.layoutIfNeeded()
        setImageView.layer.cornerRadius = setImageView.frame.size.width / 2
        setImageView.clipsToBounds = true
        setImageView.layer.borderWidth = 3.5
        setImageView.layer.borderColor = UIColor.systemBlue.withAlphaComponent(0.5).cgColor
    }
}

extension ImageSetupProfileVC: SetImageDelegate {
    func imageDidSet(_ image: UIImage?) {
        
    }
    
    func showActionSheet(_ actionSheet: UIAlertController) {
        present(actionSheet, animated: true)
    }
    
    func showImagePicker(_ imagePicker: UIImagePickerController) {
        present(imagePicker, animated: true)
    }
    
    func dismissImagePicker() {
        dismiss(animated: true)
    }
}
