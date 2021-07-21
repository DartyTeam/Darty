//
//  SetImageView.swift
//  Darty
//
//  Created by Руслан Садыков on 03.07.2021.
//

import UIKit
import AVFoundation
import PhotosUI

protocol SetImageDelegate {
    func showActionSheet(_ actionSheet: UIAlertController)
    func showCamera(_ imagePicker: UIImagePickerController)
    func showImagePicker(_ imagePicker: PHPickerViewController)
    func imagesDidSet(_ images: [UIImage])
    func dismissImagePicker()
    func showError(_ error: String)
}

final class SetImageView: BlurEffectView {
    
    // MARK: - UI Elements
    private lazy var configuration: PHPickerConfiguration = {
        var configuration = PHPickerConfiguration()
        configuration.selectionLimit = maxPhotos
        configuration.filter = .images
        return configuration
    }()
    
    private lazy var imagePicker: PHPickerViewController = {
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = self
        return picker
    }()
    
    var images: [UIImage]?
    
    let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let plusIcon: UIImageView = {
        let configIcon = UIImage.SymbolConfiguration(font: UIFont.systemFont(ofSize: 50, weight: .medium))
        let imageView = UIImageView(image: UIImage(systemName: "plus", withConfiguration: configIcon))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    // MARK: - Properties
    var delegate: SetImageDelegate?
    var maxPhotos: Int!
    var color: UIColor! {
        didSet {
            self.plusIcon.image = self.plusIcon.image?.withTintColor(color, renderingMode: .alwaysOriginal)
        }
    }
    
    // MARK: - Lifecycle
    init(delegate: SetImageDelegate? = nil, maxPhotos: Int, color: UIColor) {
        self.delegate = delegate
        self.maxPhotos = maxPhotos
        self.color = color
        super.init()
        
        plusIcon.image = plusIcon.image?.withTintColor(color, renderingMode: .alwaysOriginal)
        
        setupView()
        setupConstraints()
        addTap()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func addTap() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(viewTapped))
        addGestureRecognizer(tap)
    }
    
    private func setupView() {
        contentView.addSubview(plusIcon)
        contentView.addSubview(imageView)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            plusIcon.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            plusIcon.centerXAnchor.constraint(equalTo: self.centerXAnchor),
        ])
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: self.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
        ])
    }
    
    // MARK: - Handlers
    @objc func viewTapped() {
        showAnimation {
            self.selectPhoto()
        }
    }
    
    private func selectPhoto() {
                
        let actionSheet = UIAlertController(title: nil,
                                            message: nil,
                                            preferredStyle: .actionSheet)
        
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
        self.delegate?.showActionSheet(actionSheet)
    }
    
    private func setImages(_ images: [UIImage]) {
        for image in images {
            self.images?.append(image)
        }
        delegate?.imagesDidSet(images)
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
                        self.delegate?.showCamera(imagePicker)
                    }
                } else {
                    
                }
            }
        } else {
            delegate?.showImagePicker(imagePicker)
        }
    }
}

// MARK: - IImagePickerControllerDelegate, UINavigationControllerDelegat (Work with image)
extension SetImageView: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true, completion: nil)
        guard !results.isEmpty else { return }
        
        var images: [UIImage] = []
        
        for (i, item) in results.enumerated() {
            if item.itemProvider.canLoadObject(ofClass: UIImage.self) {
                item.itemProvider.loadObject(ofClass: UIImage.self) { (image, error) in
                    DispatchQueue.main.async {
                        if let image = image as? UIImage {
                            images.append(image)
                            if i == results.count - 1 {
                                self.delegate?.imagesDidSet(images)
                                print("asidojaosidjioasjodiajosdjoasdojasodji: ", images.count)
                            }
                        }
                    }
                }
            }
        }
    }
}

extension SetImageView: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let image = info[.editedImage] as? UIImage {
            setImages([image])
        } else {
            delegate?.showError("Ошибка получени изображения с камеры")
        }
        
        delegate?.dismissImagePicker()
    }
}
