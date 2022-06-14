//
//  PartyImagesVC.swift
//  Darty
//
//  Created by Руслан Садыков on 15.07.2021.
//

import UIKit
import PhotosUI
import Agrume
import SPAlert
import SafeSFSymbols

final class PartyImagesVC: BaseController {

    // MARK: - Constants
    private enum Constants {
        static let maxPhotosForSelect = 5
    }
    
    // MARK: - UI Elements
    private lazy var imagesListView: MultiSetImagesView = {
        let multiSetImagesView = MultiSetImagesView(
            maxPhotos: Constants.maxPhotosForSelect,
            shape: .rect,
            color: .systemPurple,
            delegate: self
        )
        return multiSetImagesView
    }()
    
    private lazy var nextButton: DButton = {
        let button = DButton(title: "Далее 􀰑")
        button.backgroundColor = .systemPurple
        button.addTarget(self, action: #selector(nextButtonTapped), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Delegate
    weak var delegate: PartyImagesDelegate?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavBar()
        setupViews()
        setupConstraints()
    }

    // MARK: - Setup views
    private func setupNavBar() {
        title = "Создание вечеринки"
        let cancelIconConfig = UIImage.SymbolConfiguration(font: UIFont.systemFont(ofSize: 20, weight: .bold))
        let cancelIconImage = UIImage(systemName: "xmark.circle.fill", withConfiguration: cancelIconConfig)?.withTintColor(.systemPurple, renderingMode: .alwaysOriginal)
        let cancelBarButtonItem = UIBarButtonItem(image: cancelIconImage, style: .plain, target: self, action: #selector(cancleAction))
        navigationItem.rightBarButtonItem = cancelBarButtonItem
    }
    
    private func setupViews() {
        view.backgroundColor = .systemBackground
        view.addSubview(nextButton)
        view.addSubview(imagesListView)
    }
    
    // MARK: - Handlers
    @objc private func nextButtonTapped() {
        let images = imagesListView.images.map({ $0.image })
        guard !images.isEmpty else {
            SPAlert.present(
                title: "",
                message: "Необходимо выбрать не менее одного изображения",
                preset: .custom(UIImage(.photo)),
                haptic: .warning
            )
            return
        }
        delegate?.goNext(with: images)
    }
    
    @objc private func cancleAction() {
        navigationController?.popToRootViewController(animated: true)
    }
}

// MARK: - Setup constraints
extension PartyImagesVC {
    private func setupConstraints() {
        nextButton.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(UIButton.defaultButtonHeight)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-32)
        }
        
        imagesListView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(32)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(nextButton.snp.top).offset(-32)
        }
    }
}

// MARK: - MultiSetImagesViewDelegate
extension PartyImagesVC: MultiSetImagesViewDelegate {
    func showFullscreen(_ agrume: Agrume) {
        agrume.show(from: self)
    }

    func showAlertController(_ alertController: UIAlertController) {
        present(alertController, animated: true, completion: nil)
    }
    
    func dismissImagePicker() {
        dismiss(animated: true, completion: nil)
    }
    
    func showCamera(_ imagePicker: UIImagePickerController) {
        present(imagePicker, animated: true, completion: nil)
    }
    
    func showImagePicker(_ imagePicker: PHPickerViewController) {
        present(imagePicker, animated: true, completion: nil)
    }
    
    func showError(_ error: String) {
        SPAlert.present(title: error, preset: .error)
    }
}
