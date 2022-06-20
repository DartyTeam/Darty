//
//  SetImageView.swift
//  Darty
//
//  Created by Руслан Садыков on 03.07.2021.
//

import UIKit
import AVFoundation
import PhotosUI
import SPAlert

protocol SetImageDelegate {
    func showAlertController(_ alertController: UIAlertController)
    func showCamera(_ imagePicker: UIImagePickerController)
    func showImagePicker(_ imagePicker: PHPickerViewController)
    func didSet(image: UniqueImage)
    func clearImages()
    func dismissImagePicker()
    func showError(_ error: String)
}

final class SetImageView: BlurEffectView {
    
    // MARK: - UI Elements
    private var phpicker: PHPickerViewController?
    
    let imageView: UIImageView = {
        let imageView = UIImageView()
        return imageView
    }()
    
    private let plusIcon: UIImageView = {
        let configIcon = UIImage.SymbolConfiguration(font: UIFont.systemFont(ofSize: 50, weight: .medium))
        let imageView = UIImageView(image: UIImage(systemName: "plus", withConfiguration: configIcon))
        return imageView
    }()
    
    // MARK: - Delegate
    var delegate: SetImageDelegate?
    
    // MARK: - Lifecycle
    init(delegate: SetImageDelegate? = nil) {
        self.delegate = delegate
        super.init()
        plusIcon.image = plusIcon.image?.withTintColor(Colors.Elements.element, renderingMode: .alwaysOriginal)
        setupView()
        setupConstraints()
        addTap()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup
    func setup(phpicker: PHPickerViewController) {
        phpicker.delegate = self
        self.phpicker = phpicker
    }

    private func setupView() {
        contentView.addSubview(plusIcon)
        contentView.addSubview(imageView)
    }
    
    private func setupConstraints() {
        plusIcon.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
        imageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    private func addTap() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(viewTapped))
        addGestureRecognizer(tap)
    }
    
    // MARK: - Handlers
    @objc func viewTapped() {
        showAnimation {
            self.selectPhoto()
        }
    }

    // MARK: - Functions
    private func selectPhoto() {
        let actionSheet = UIAlertController(
            title: nil,
            message: nil,
            preferredStyle: .actionSheet
        )
        
        let cameraIcon = UIImage(systemName: "camera")
        let camera = UIAlertAction(title: "Камера", style: .default) { _ in
            self.chooseImagePicker(source: .camera)
        }
        camera.setValue(cameraIcon, forKey: "image")
        camera.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
        actionSheet.addAction(camera)
        
        let photoIcon = UIImage(systemName: "photo")
        let photo = UIAlertAction(title: "Фото", style: .default) { _ in
            self.chooseImagePicker(source: .photoLibrary)
        }
        photo.setValue(photoIcon, forKey: "image")
        photo.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
        actionSheet.addAction(photo)
        
        let cancel = UIAlertAction(title: "Отмена", style: .cancel)
        actionSheet.addAction(cancel)
        self.delegate?.showAlertController(actionSheet)
    }
    
    func chooseImagePicker(source: UIImagePickerController.SourceType) {
        if source == .camera {
            AVCaptureDevice.requestAccess(for: AVMediaType.video) { response in
                if response {
                    if UIImagePickerController.isSourceTypeAvailable(source) {
                        let imagePicker = UIImagePickerController()
                        imagePicker.delegate = self
                        imagePicker.allowsEditing = true
                        imagePicker.sourceType = source
                        DispatchQueue.main.async {
                            self.delegate?.showCamera(imagePicker)
                        }
                    }
                } else {
                    let alertController = UIAlertController(style: .alert, title: "Нет доступа к камере", message: "Необходимо пройти в настройки и разрешить доступ")
                    let settingsAction = UIAlertAction(title: "Перейти в настройки", style: .default) { _ in
                        guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
                            return
                        }
                        if UIApplication.shared.canOpenURL(settingsUrl) {
                            UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                                print("Settings opened: \(success)") // Prints true
                            })
                        }
                    }
                    alertController.addAction(settingsAction)
                    let cancelAction = UIAlertAction(title: "Отмена", style: .default, handler: nil)
                    alertController.addAction(cancelAction)
                    DispatchQueue.main.async {
                        self.delegate?.showAlertController(alertController)
                    }
                }
            }
        } else {
            guard let phpicker = phpicker else {
                SPAlert.present(
                    title: "Ошибка",
                    message: "Не удалось получить доступ к Галерее",
                    preset: .error
                )
                return
            }
            delegate?.showImagePicker(phpicker)
        }
    }
}

// MARK: - ImagePickerControllerDelegate, UINavigationControllerDelegat (Work with image)
extension SetImageView: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true, completion: nil)
        guard !results.isEmpty else { return }
        delegate?.clearImages()
        for (_, item) in results.enumerated() {
            guard item.itemProvider.canLoadObject(ofClass: UIImage.self) else { return }
            item.itemProvider.loadObject(ofClass: UIImage.self) { (image, error) in
                guard let image = image as? UIImage else { return }
                DispatchQueue.main.async {
                    self.delegate?.didSet(image: UniqueImage(
                        id: item.assetIdentifier ?? UUID().uuidString,
                        image: image)
                    )
                }
            }
        }
    }
}

// MARK: - UIImagePickerControllerDelegate, UINavigationControllerDelegate
extension SetImageView: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let image = info[.editedImage] as? UIImage {
            delegate?.didSet(image: UniqueImage(id: UUID().uuidString, image: image))
        } else {
            delegate?.showError("Ошибка получени изображения с камеры")
        }
        
        delegate?.dismissImagePicker()
    }
}
