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
    case myInfo
}

// MARK: - OverlayNotch
enum OverlayNotch: Int, CaseIterable {
    case minimum, maximum
}

import UIKit
import OverlayContainer
import Hero
import SPAlert

// MARK: - OverlayContainer
final class AboutUserVC: OverlayContainerViewController, OverlayContainerViewControllerDelegate {
    
    // MARK: - UI Elements
    private let shareButton: UIButton = {
        let button = UIButton(type: .system)
        let configIcon = UIImage.SymbolConfiguration(font: UIFont.systemFont(ofSize: 18, weight: .bold))
        let shareIcon = UIImage(systemName: "square.and.arrow.up", withConfiguration: configIcon)?
            .withTintColor(.systemOrange, renderingMode: .alwaysOriginal)
        button.setImage(shareIcon, for: UIControl.State())
        button.layer.cornerRadius = 22
        button.clipsToBounds = true
        button.addTarget(self, action: #selector(shareAction), for: .touchUpInside)
        button.addBlurEffect()
        return button
    }()
    
    private let backButton: UIButton = {
        let button = UIButton(type: .system)
        let configIcon = UIImage.SymbolConfiguration(font: UIFont.systemFont(ofSize: 18, weight: .bold))
        let backIcon = UIImage(systemName: "chevron.backward", withConfiguration: configIcon)?
            .withTintColor(.systemOrange, renderingMode: .alwaysOriginal)
        button.setImage(backIcon, for: UIControl.State())
        button.layer.cornerRadius = 22
        button.clipsToBounds = true
        button.addTarget(self, action: #selector(backAction), for: .touchUpInside)
        button.addBlurEffect()
        return button
    }()

    // MARK: - Delegate
    weak var partyRequestDelegate: AboutUserPartyRequestDelegate? {
        didSet {
            infoUserVC.partyRequestDelegate = partyRequestDelegate
        }
    }
    
    weak var chatRequestDelegate: AboutUserChatRequestDelegate? {
        didSet {
            infoUserVC.chatRequestDelegate = chatRequestDelegate
        }
    }
    
    // MARK: - Properties
    private let type: AboutUserVCType
    private var userId: String?
    private let photosUserVC: PhotosUserVC
    private let infoUserVC: InfoUserVC
  
    // MARK: - Lifecycle
    init(userId: String, message: String) {
        self.userId = userId
        self.type = .partyRequest
        photosUserVC = PhotosUserVC()
        infoUserVC = InfoUserVC(userId: userId, accentColor: .systemOrange, message: message)
        super.init(style: .rigid)
    }

    init(userData: UserModel, message: String) {
        self.type = .partyRequest
        photosUserVC = PhotosUserVC(image: userData.avatarStringURL)
        infoUserVC = InfoUserVC(userData: userData, accentColor: .systemOrange, message: message)
        super.init(style: .rigid)
    }
    
    init(userId: String,
         preloadedUserImage: UIImage? = nil,
         coordinatorDelegate: AccountCoordinatorDelegate? = nil) {
        self.userId = userId
        self.type = userId == AuthService.shared.currentUser.id ? .myInfo : .info
        photosUserVC = PhotosUserVC(preloadedUserImage: preloadedUserImage)
        infoUserVC = InfoUserVC(userId: userId, accentColor: .systemOrange, preloadedUserImage: preloadedUserImage)
        infoUserVC.coordinatorDelegate = coordinatorDelegate
        super.init(style: .rigid)
    }

    init(userData: UserModel,
         preloadedUserImage: UIImage? = nil,
         coordinatorDelegate: AccountCoordinatorDelegate? = nil) {
        self.type = userData.id == AuthService.shared.currentUser.id ? .myInfo : .info
        photosUserVC = PhotosUserVC(preloadedUserImage: preloadedUserImage)
        infoUserVC = InfoUserVC(userData: userData, accentColor: .systemOrange, preloadedUserImage: preloadedUserImage)
        infoUserVC.coordinatorDelegate = coordinatorDelegate
        super.init(style: .rigid)
    }
    
    private var chatData: RecentChatModel? = nil
    init(userId: String, chatData: RecentChatModel) {
        self.userId = userId
        self.chatData = chatData
        self.type = .messageRequest
        photosUserVC = PhotosUserVC()
        infoUserVC = InfoUserVC(userId: userId, chatData: chatData, accentColor: .systemOrange)
        super.init(style: .rigid)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        if let userId = userId {
            fetchUserBy(id: userId)
        }
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillAppear), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        viewControllers = [photosUserVC, infoUserVC]
        delegate = self
        setupNavigationBar()
        setupViews()
        setupConstraints()
        moveOverlay(toNotchAt: 0, animated: false)
        setIsTabBarHidden(true)
    }
    
    func overlayContainerViewController(_ containerViewController: OverlayContainerViewController,
                                        scrollViewDrivingOverlay overlayViewController: UIViewController) -> UIScrollView? {
        return (viewControllers.last as? InfoUserVC)?.scrollView
    }
    
    func overlayContainerViewController(_ containerViewController: OverlayContainerViewController,
                                        willMoveOverlay overlayViewController: UIViewController,
                                        toNotchAt index: Int) {
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
        if !isBeingPresented {
            view.addSubview(backButton)
        }
        view.addSubview(shareButton)
    }
    
    private func setupConstraints() {
        shareButton.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(-2)
            make.right.equalToSuperview().offset(-8)
            make.size.equalTo(44)
        }
        if !isBeingPresented {
            backButton.snp.makeConstraints { make in
                make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(-2)
                make.left.equalToSuperview().offset(4)
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
    private func fetchUserBy(id: String) {
        FirestoreService.shared.getUser(by: id) { result in
            switch result {
            case .success(let user):
                self.photosUserVC.setupWith(imageStringUrl: user.id)
            case .failure(let error):
                SPAlert.present(title: error.localizedDescription, preset: .error)
            }
        }
    }

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
