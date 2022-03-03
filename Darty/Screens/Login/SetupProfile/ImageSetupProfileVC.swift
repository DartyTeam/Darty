//
//  ImageSetupProfileVC.swift
//  Darty
//
//  Created by Руслан Садыков on 02.07.2021.
//

import UIKit
import FirebaseAuth
import PhotosUI
import Agrume

final class ImageSetupProfileVC: UIViewController {
        
    // MARK: - UI Elements
    private lazy var nextButton: UIButton = {
        let button = UIButton(title: "Далее 􀰑")
        button.backgroundColor = .systemBlue
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(nextButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var setImageView: MultiSetImagesView = {
        let setImageView = MultiSetImagesView(maxPhotos: 1, shape: .round, color: .systemBlue, delegate: self)
        setImageView.translatesAutoresizingMaskIntoConstraints = false
        return setImageView
    }()
    
    // MARK: - Delegate
    weak var delegate: ImageSetupProfileDelegate?
    
    // MARK: - Lifecycle
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
    @objc private func nextButtonTapped() {
        guard let userImage = setImageView.images.first else {
            showAlert(title: "Выберите изображение", message: "")
            return
        }
        delegate?.goNext(with: userImage)
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
        
        setImageView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(32)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(nextButton.snp.top).offset(-32)
        }
    }
}

// MARK: - MultiSetImagesViewDelegate
extension ImageSetupProfileVC: MultiSetImagesViewDelegate {
    func showFullscreen(_ agrume: Agrume) {
        agrume.show(from: self)
    }
    
    func showCamera(_ imagePicker: UIImagePickerController) {
        present(imagePicker, animated: true, completion: nil)
    }
    
    func showImagePicker(_ imagePicker: PHPickerViewController) {
        present(imagePicker, animated: true)
    }
    
    func showError(_ error: String) {
        showAlert(title: "Ошибка", message: error)
    }
    
    func showActionSheet(_ actionSheet: UIAlertController) {
        present(actionSheet, animated: true)
    }
    
    func dismissImagePicker() {
        dismiss(animated: true)
    }
}
