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
    case minimum, medium, maximum
}

import UIKit
import OverlayContainer
import Hero
import SPAlert
import SafeSFSymbols

// MARK: - OverlayContainer
final class AboutUserVC: OverlayContainerViewController {

    // MARK: - UI Elements
    private let shareButton: UIBarButtonItem = {
        let configIcon = UIImage.SymbolConfiguration(font: UIFont.systemFont(ofSize: 20, weight: .bold))
        let shareIcon = UIImage(SPSafeSymbol.square.andArrowUp).withConfiguration(configIcon)
            .withTintColor(Colors.Elements.element, renderingMode: .alwaysOriginal)
        let button = UIBarButtonItem(image: shareIcon, style: .plain, target: self, action: #selector(shareAction))
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
    private var userData: UserModel?
    private let photosUserVC: PhotosUserVC
    private let infoUserVC: InfoUserVC
  
    // MARK: - Lifecycle
    init(userId: String, message: String) {
        self.userId = userId
        self.type = .partyRequest
        photosUserVC = PhotosUserVC()
        infoUserVC = InfoUserVC(message: message)
        super.init(style: .rigid)
    }

    init(userData: UserModel, message: String) {
        self.type = .partyRequest
        self.userData = userData
        photosUserVC = PhotosUserVC(image: userData.avatarStringURL)
        infoUserVC = InfoUserVC(message: message)
        super.init(style: .rigid)
    }
    
    init(userId: String,
         preloadedUserImage: UIImage? = nil,
         coordinatorDelegate: AccountCoordinatorDelegate? = nil) {
        self.userId = userId
        self.type = userId == AuthService.shared.currentUser.id ? .myInfo : .info
        photosUserVC = PhotosUserVC(preloadedUserImage: preloadedUserImage)
        infoUserVC = InfoUserVC(type: type, preloadedUserImage: preloadedUserImage)
        infoUserVC.coordinatorDelegate = coordinatorDelegate
        super.init(style: .rigid)
    }

    init(userData: UserModel,
         preloadedUserImage: UIImage? = nil,
         coordinatorDelegate: AccountCoordinatorDelegate? = nil) {
        self.userData = userData
        self.type = userData.id == AuthService.shared.currentUser.id ? .myInfo : .info
        photosUserVC = PhotosUserVC(preloadedUserImage: preloadedUserImage)
        infoUserVC = InfoUserVC(type: type, preloadedUserImage: preloadedUserImage)
        infoUserVC.coordinatorDelegate = coordinatorDelegate
        super.init(style: .rigid)
    }
    
    private var chatData: RecentChatModel? = nil
    init(userId: String, chatData: RecentChatModel) {
        self.userId = userId
        self.chatData = chatData
        self.type = .messageRequest
        photosUserVC = PhotosUserVC()
        infoUserVC = InfoUserVC(chatData: chatData)
        super.init(style: .rigid)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupBaseNavBar(withClear: true, rightBarButtonItems: [shareButton])
        if let userId = userId {
            fetchUserBy(id: userId)
        } else if let userData = userData {
            setupWith(userData: userData)
        }
        setupKeyboardNotifications()
        viewControllers = [photosUserVC, infoUserVC]
        delegate = self
        navigationController?.navigationItem.rightBarButtonItems = [shareButton]
        moveOverlay(toNotchAt: 0, animated: false)
        setIsTabBarHidden(true)
    }

    private func setupKeyboardNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillAppear),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }

    // MARK: - Handlers
    private func fetchUserBy(id: String) {
        FirestoreService.shared.getUser(by: id) { result in
            switch result {
            case .success(let user):
                print("asdiojasdoijasodijasodijasdi: ")
                self.setupWith(userData: user)
            case .failure(let error):
                SPAlert.present(title: error.localizedDescription, preset: .error) {
                    self.dismiss(animated: true)
                    self.navigationController?.popViewController(animated: true)
                }
            }
        }
    }

    private func setupWith(userData: UserModel) {
        photosUserVC.setupWith(imageStringUrl: userData.avatarStringURL)
        infoUserVC.setupWith(userData: userData)
    }

    @objc private func keyboardWillHide(notification: NSNotification) {
        moveOverlay(toNotchAt: .minimum)
        drivingScrollView?.isScrollEnabled = true
    }
    
    @objc private func keyboardWillAppear(notification: NSNotification) {
        moveOverlay(toNotchAt: .medium)
        drivingScrollView?.isScrollEnabled = false
    }
    
    @objc private func shareAction() {
        ShareHelper.share(user: FirestoreService.shared.currentUser, from: self)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
}

extension AboutUserVC: OverlayContainerViewControllerDelegate {
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
        case .maximum, .medium:
            arrow?.update(to: .down, animated: true)
        case .some(_), .none:
            break
        }
    }

    func overlayContainerViewController(_ containerViewController: OverlayContainerViewController,
                                        overlayTranslationFunctionForOverlay overlayViewController: UIViewController) -> OverlayTranslationFunction? {
        let function = RubberBandOverlayTranslationFunction()
        function.factor = 0
        function.bouncesAtMinimumHeight = false
        return function
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
        case .medium:
            return availableSpace - view.safeAreaInsets.top - 64
        case .maximum:
            return availableSpace - view.safeAreaInsets.top
        }
    }

    private func moveOverlay(toNotchAt: OverlayNotch) {
        moveOverlay(toNotchAt: toNotchAt.rawValue, animated: true)
    }
}
