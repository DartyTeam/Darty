//
//  AboutUserVC.swift
//  Darty
//
//  Created by Руслан Садыков on 26.07.2021.
//

enum AboutUserVCType {
    case info
    case messageRequest
    case partyRequest
}

// MARK: - OverlayNotch
enum OverlayNotch: Int, CaseIterable {
    case minimum, maximum
}

import UIKit
import OverlayContainer

// MARK: - OverlayContainer
final class AboutUserVC: OverlayContainerViewController, OverlayContainerViewControllerDelegate {
    
    // MARK: - UI Elements
    let shareButton: UIButton = {
        let button = UIButton(type: .system)
        let configIcon = UIImage.SymbolConfiguration(font: UIFont.systemFont(ofSize: 20, weight: .bold))
        let trashIcon = UIImage(systemName: "square.and.arrow.up", withConfiguration: configIcon)?.withTintColor(.systemOrange, renderingMode: .alwaysOriginal)
        button.setImage(trashIcon, for: .normal)
        button.layer.cornerRadius = 22
        button.clipsToBounds = true
        button.addTarget(self, action: #selector(shareAction), for: .touchUpInside)
        button.addBlurEffect()
        return button
    }()
    
    let backButton: UIButton = {
        let button = UIButton(type: .system)
        let configIcon = UIImage.SymbolConfiguration(font: UIFont.systemFont(ofSize: 20, weight: .bold))
        let trashIcon = UIImage(systemName: "chevron.backward", withConfiguration: configIcon)?.withTintColor(.systemOrange, renderingMode: .alwaysOriginal)
        button.setImage(trashIcon, for: .normal)
        button.layer.cornerRadius = 22
        button.clipsToBounds = true
        button.addTarget(self, action: #selector(backAction), for: .touchUpInside)
        button.addBlurEffect()
        return button
    }()
    
    // MARK: - Properties
    private var type: AboutUserVCType
    private var userData: UserModel
    private let photosUserVC: PhotosUserVC
    private let infoUserVC: InfoUserVC
    
    // MARK: - Lifecycle
    required init(userData: UserModel, type: AboutUserVCType) {
        self.userData = userData
        self.type = type
        photosUserVC = PhotosUserVC(image: userData.avatarStringURL)
        infoUserVC = InfoUserVC(userData: userData, type: type)
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
        setupNavigationBar()
        setupViews()
        setupConstraints()
        moveOverlay(toNotchAt: 0, animated: true)
        setIsTabBarHidden(true)
    }
    
    func overlayContainerViewController(_ containerViewController: OverlayContainerViewController,
                                        scrollViewDrivingOverlay overlayViewController: UIViewController) -> UIScrollView? {
        return (viewControllers.last as? InfoUserVC)?.scrollView
    }
    
    func overlayContainerViewController(_ containerViewController: OverlayContainerViewController, willMoveOverlay overlayViewController: UIViewController, toNotchAt index: Int) {
        let arrow = (viewControllers.last as? InfoUserVC)?.arrowDirectionImageView
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
    
    private func setupViews() {
        view.addSubview(shareButton)
        view.addSubview(backButton)
    }
    
    private func setupConstraints() {
        shareButton.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(12)
            make.right.equalToSuperview().offset(-16)
            make.size.equalTo(44)
        }
        
        backButton.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(12)
            make.left.equalToSuperview().offset(16)
            make.size.equalTo(44)
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
    
    @objc private func shareAction() {
        
    }
    
    @objc private func backAction() {
        navigationController?.popViewController(animated: true)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
}