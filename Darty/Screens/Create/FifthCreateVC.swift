//
//  FifthCreateVC.swift
//  Darty
//
//  Created by Руслан Садыков on 15.07.2021.
//

import UIKit
import FirebaseAuth
import SnapKit
import PhotosUI
import Agrume

final class FifthCreateVC: UIViewController {
    
    private enum Constants {
        static let titleFont: UIFont? = .sfProDisplay(ofSize: 16, weight: .semibold)
        static let countFont: UIFont? = .sfProDisplay(ofSize: 22, weight: .semibold)
        static let segmentFont: UIFont? = .sfProRounded(ofSize: 16, weight: .medium)
        static let countGuestsText = "Кол-во гостей"
        static let minAgeText = "Мин. возраст"
        static let priceText = "Цена за вход"
    }
    
    // MARK: - UI Elements
    private lazy var imagesListView: MultiSetImagesView = {
        let multiSetImagesView = MultiSetImagesView(delegate: self, maxPhotos: 5, shape: .rect, color: .systemPurple)
        return multiSetImagesView
    }()
    
    private lazy var nextButton: UIButton = {
        let button = UIButton(title: "Далее 􀰑")
        button.backgroundColor = .systemPurple
        button.addTarget(self, action: #selector(nextButtonTapped), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Properties
    private let currentUser: UserModel
    private var setuppedParty: SetuppedParty
    
    // MARK: - Lifecycle
    init(currentUser: UserModel, setuppedParty: SetuppedParty) {
        self.currentUser = currentUser
        self.setuppedParty = setuppedParty
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavBar()
        setupViews()
        setupConstraints()
    }
    
    private func setupNavBar() {
        setNavigationBar(withColor: .systemPurple, title: "Создание вечеринки")
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
        let images = imagesListView.images
        guard !images.isEmpty else {
            showAlert(title: "Необходимо выбрать не менее одного изображения", message: "")
            return
        }
        
        setuppedParty.images = images
        
        let sixthCreateVC = SixthCreateVC(currentUser: currentUser, setuppedParty: setuppedParty)
        navigationController?.pushViewController(sixthCreateVC, animated: true)
    }
    
    @objc private func cancleAction() {
        navigationController?.popToRootViewController(animated: true)
    }
}

// MARK: - Setup constraints
extension FifthCreateVC {
    
    private func setupConstraints() {
        nextButton.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(50)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-32)
        }
        
        imagesListView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(32)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(nextButton.snp.top).offset(-32)
        }
    }
}

extension FifthCreateVC: MultiSetImagesViewDelegate {
    func showFullscreen(_ agrume: Agrume) {
        agrume.show(from: self)
    }
    
    func showActionSheet(_ actionSheet: UIAlertController) {
        present(actionSheet, animated: true, completion: nil)
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
        showError(error)
    }
}


