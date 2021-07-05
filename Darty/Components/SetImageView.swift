//
//  SetImageView.swift
//  Darty
//
//  Created by Руслан Садыков on 03.07.2021.
//

import UIKit
import AVFoundation
import Photos

protocol SetImageDelegate {
    func showActionSheet(_ actionSheet: UIAlertController)
    func showImagePicker(_ imagePicker: UIImagePickerController)
    func imageDidSet(_ image: UIImage?)
    func dismissImagePicker()
}

final class SetImageView: BlurEffectView {
    
    // MARK: - UI Elements
    var image: UIImage?
    
    private let imageView: UIImageView = {
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
    private var delegate: SetImageDelegate!
    
    // MARK: - Lifecycle
    init(delegate: SetImageDelegate) {
        self.delegate = delegate
        super.init(effect: nil)
        
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
        
        var canShowAlert = false
        
        let actionSheet = UIAlertController(title: nil,
                                            message: nil,
                                            preferredStyle: .actionSheet)
        
        let queue = DispatchGroup()
        
        queue.enter()
        //Camera
        AVCaptureDevice.requestAccess(for: AVMediaType.video) { response in
            if response {
                let cameraIcon = UIImage(systemName: "camera")
                
                let camera = UIAlertAction(title: "Камера", style: .default) { _ in
                    self.chooseImagePicker(source: .camera)
                }
                camera.setValue(cameraIcon, forKey: "image")
                camera.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
                
                DispatchQueue.main.async {
                    actionSheet.addAction(camera)
                }
                
                canShowAlert = true
            } else {
                
            }
            
            queue.leave()
        }
        
        func addPhoto() {
            let photoIcon = UIImage(systemName: "photo")
            let photo = UIAlertAction(title: "Фото", style: .default) { _ in
                self.chooseImagePicker(source: .photoLibrary)
            }
            photo.setValue(photoIcon, forKey: "image")
            photo.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
            
            DispatchQueue.main.async {
                actionSheet.addAction(photo)
            }
            
            canShowAlert = true
        }
        
        //Photos
        let photos = PHPhotoLibrary.authorizationStatus()
        if photos == .notDetermined {
            queue.enter()
            PHPhotoLibrary.requestAuthorization( { status in
                if status == .authorized {
                    addPhoto()
                } else {
                    
                }
            })
            
            queue.leave()
        } else {
            addPhoto()
        }
        
        queue.notify(queue: DispatchQueue.main) {
            
            if canShowAlert {
                let cancel = UIAlertAction(title: "Отмена", style: .cancel)
                
                actionSheet.addAction(cancel)
                
                self.delegate.showActionSheet(actionSheet)
            }
        }
    }
    
    private func setImage(_ image: UIImage?) {
        imageView.image = image
        self.image = image
        delegate.imageDidSet(image)
    }
}

// MARK: - IImagePickerControllerDelegate, UINavigationControllerDelegat (Work with image)
extension SetImageView: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func chooseImagePicker(source: UIImagePickerController.SourceType) {
        
        if UIImagePickerController.isSourceTypeAvailable(source) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.allowsEditing = true
            imagePicker.sourceType = source
            delegate.showImagePicker(imagePicker)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        setImage(info[.editedImage] as? UIImage)
        
        delegate.dismissImagePicker()
    }
}
