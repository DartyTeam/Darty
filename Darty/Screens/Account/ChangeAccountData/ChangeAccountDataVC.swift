
import UIKit
import AVFoundation
import PhotosUI
import SPAlert
import OverlayContainer

// MARK: - OverlayContainer
final class ChangeAccountDataVC: OverlayContainerViewController, OverlayContainerViewControllerDelegate {
    
    // MARK: - UI Elements
    private let photoButton: UIButton = {
        let button = UIButton(type: .system)
        let configIcon = UIImage.SymbolConfiguration(font: UIFont.systemFont(ofSize: 18, weight: .bold))
        let photoIcon = UIImage(systemName: "photo", withConfiguration: configIcon)?.withTintColor(.systemIndigo, renderingMode: .alwaysOriginal)
        button.setImage(photoIcon, for: UIControl.State())
        button.layer.cornerRadius = 22
        button.clipsToBounds = true
        button.addTarget(self, action: #selector(changePhotoAction), for: .touchUpInside)
        button.addBlurEffect()
        return button
    }()
    
    private let backButton: UIButton = {
        let button = UIButton(type: .system)
        let configIcon = UIImage.SymbolConfiguration(font: UIFont.systemFont(ofSize: 18, weight: .bold))
        let backIcon = UIImage(systemName: "chevron.backward", withConfiguration: configIcon)?.withTintColor(.systemIndigo, renderingMode: .alwaysOriginal)
        button.setImage(backIcon, for: UIControl.State())
        button.layer.cornerRadius = 22
        button.clipsToBounds = true
        button.addTarget(self, action: #selector(backAction), for: .touchUpInside)
        button.addBlurEffect()
        return button
    }()
    
    private lazy var configuration: PHPickerConfiguration = {
        var configuration = PHPickerConfiguration()
        configuration.selectionLimit = 1
        configuration.filter = .images
        return configuration
    }()
    
    private lazy var imagePicker: PHPickerViewController = {
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = self
        return picker
    }()
    
    // MARK: - Properties
    private let userData: UserModel = AuthService.shared.currentUser!
    private let photosUserVC: PhotosUserVC
    private let infoUserVC: ChangeAccountDataInfoViewVC
  
    // MARK: - Init
    init() {
        photosUserVC = PhotosUserVC(image: userData.avatarStringURL)
        infoUserVC = ChangeAccountDataInfoViewVC(userData: userData, accentColor: .systemIndigo)
        super.init(style: .rigid)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillAppear), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        self.viewControllers = [photosUserVC, infoUserVC]
        self.delegate = self
        
        drivingScrollView = (viewControllers.last as? ChangeAccountDataInfoViewVC)?.scrollView
        setupViews()
        setupConstraints()
        moveOverlay(toNotchAt: 0, animated: true)
        setIsTabBarHidden(true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupNavigationBar()
    }
    
    func overlayContainerViewController(_ containerViewController: OverlayContainerViewController, willMoveOverlay overlayViewController: UIViewController, toNotchAt index: Int) {
        let arrow = (viewControllers.last as? ChangeAccountDataInfoViewVC)?.arrowDirectionImageView
        let notch = OverlayNotch(rawValue: index)
        switch notch {
        case .minimum:
            arrow?.update(to: .middle, animated: true)
            self.view.endEditing(true)
        case .maximum:
            arrow?.update(to: .down, animated: true)
        case .some(_), .none:
            break
        }
    }

    // MARK: - Setup views
    private func setupViews() {
        if !isBeingPresented {
            view.addSubview(backButton)
        }
        view.addSubview(photoButton)
    }
    
    private func setupConstraints() {
        photoButton.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(12)
            make.right.equalToSuperview().offset(-16)
            make.size.equalTo(44)
        }
        if !isBeingPresented {
            backButton.snp.makeConstraints { make in
                make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(12)
                make.left.equalToSuperview().offset(16)
                make.size.equalTo(44)
            }
        }
    }
    
    private func setupNavigationBar() {
        navigationController?.setNavigationBarHidden(true, animated: true)
    }

    // MARK: - OverlayContainerViewControllerDelegate
    func numberOfNotches(in containerViewController: OverlayContainerViewController) -> Int {
        OverlayNotch.allCases.count
    }
    
    func overlayContainerViewController(_ containerViewController: OverlayContainerViewController,
                                        heightForNotchAt index: Int,
                                        availableSpace: CGFloat) -> CGFloat {
        switch OverlayNotch.allCases[index] {
        case .minimum:
            return availableSpace - view.frame.size.width + 32
        case .maximum:
            return availableSpace - view.safeAreaInsets.top - 64
        }
    }
    
    private func moveOverlay(toNotchAt: OverlayNotch) {
        moveOverlay(toNotchAt: toNotchAt.rawValue, animated: true)
    }
    
    // MARK: - Handlers
    @objc private func keyboardWillHide(notification: NSNotification) {
        moveOverlay(toNotchAt: .minimum)
        drivingScrollView?.isScrollEnabled = true
    }
    
    @objc private func keyboardWillAppear(notification: NSNotification) {
        moveOverlay(toNotchAt: .maximum)
        drivingScrollView?.isScrollEnabled = false
    }
    
    func overlayContainerViewController(_ containerViewController: OverlayContainerViewController,
                                        overlayTranslationFunctionForOverlay overlayViewController: UIViewController) -> OverlayTranslationFunction? {
        let function = RubberBandOverlayTranslationFunction()
        function.factor = 0
        function.bouncesAtMinimumHeight = false
        return function
    }
    
    @objc private func changePhotoAction() {
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
        present(actionSheet, animated: true, completion: nil)
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
                        self.present(imagePicker, animated: true, completion: nil)
                    }
                } else {
                    
                }
            }
        } else {
            present(imagePicker, animated: true, completion: nil)
        }
    }
    
    @objc private func backAction() {
        navigationController?.popViewController(animated: true)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    private func changeUserImage(to image: UIImage) {
        startLoading()
        StorageService.shared.upload(photo: image) { [weak self] (result) in
            switch result {

            case .success(let url):
                AuthService.shared.currentUser.avatarStringURL = url.absoluteString
                FirestoreService.shared.updateUserInformation(userData: AuthService.shared.currentUser) { [weak self] result in
                    switch result {
                    
                    case .success():
                        DispatchQueue.main.async {
                            self?.stopLoading()
                            self?.photosUserVC.imageView.image = image
                            self?.photosUserVC.imageView.focusOnFaces = true
                        }
                    case .failure(let error):
                        DispatchQueue.main.async {
                            self?.stopLoading()
                            SPAlert.present(title: error.localizedDescription, preset: .error)
                        }
                    }
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    self?.stopLoading()
                    SPAlert.present(title: error.localizedDescription, preset: .error)
                }
            }
        }
    }
}

// MARK: - IImagePickerControllerDelegate, UINavigationControllerDelegat (Work with image)
extension ChangeAccountDataVC: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true, completion: nil)
        guard !results.isEmpty else { return }
        
        if results.first?.itemProvider.canLoadObject(ofClass: UIImage.self) ?? false {
            results.first?.itemProvider.loadObject(ofClass: UIImage.self) { (image, error) in
                DispatchQueue.main.async {
                    if let image = image as? UIImage {
                        self.changeUserImage(to: image)
                    }
                }
            }
        }
    }
}

// MARK: - UIImagePickerControllerDelegate, UINavigationControllerDelegate
extension ChangeAccountDataVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let image = info[.editedImage] as? UIImage {
            self.changeUserImage(to: image)
        } else {
            SPAlert.present(title: "Ошибка получени изображения с камеры", preset: .error)
        }
        
        dismiss(animated: true, completion: nil)
    }
}
