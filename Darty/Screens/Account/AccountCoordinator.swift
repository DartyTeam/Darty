//
//  AccountCoordinator.swift
//  Darty
//
//  Created by Руслан Садыков on 27.03.2022.
//

import UIKit

protocol AccountCoordinatorDelegate: AnyObject {
    func openAbout(userData: UserModel, preloadedUserImage: UIImage?)
    func openChangeInfo(preloadedUserImage: UIImage?, isNeedAnimatedShowImage: Bool)
    func openContactsWithUs()
    func openChangePhone()
    func openNotificationsSettings()
    func openChangeInterests()
    func popVC()
}

final class AccountCoordinator: Coordinator {
    var childCoordinators = [Coordinator]()
    var navigationController: UINavigationController

    private var changeAccountDataVC: ChangeAccountDataVC?

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    func start() {
        let accountVC = AccountVC()
        accountVC.delegate = self
        navigationController.setViewControllers([accountVC], animated: false)
        navigationController.hero.isEnabled = true
    }

    private var isEnabledAnimationNavigation = false {
        didSet {
            navigationController.hero.navigationAnimationType = isEnabledAnimationNavigation ? .auto : .none
        }
    }
}

extension AccountCoordinator: AccountCoordinatorDelegate {
    func openAbout(userData: UserModel, preloadedUserImage: UIImage?) {
        let aboutUserVC = AboutUserVC(
            userData: userData,
            preloadedUserImage: preloadedUserImage,
            coordinatorDelegate: self
        )
        isEnabledAnimationNavigation = false
        navigationController.pushViewController(aboutUserVC, animated: true)
    }

    func openChangeInfo(preloadedUserImage: UIImage?, isNeedAnimatedShowImage: Bool = true) {
        changeAccountDataVC = ChangeAccountDataVC(
            preloadedUserImage: preloadedUserImage,
            isNeedAnimatedShowImage: isNeedAnimatedShowImage,
            coordinatorDelegate: self
        )
        isEnabledAnimationNavigation = false
        guard let changeAccountDataVC = changeAccountDataVC else { return }
        navigationController.pushViewController(changeAccountDataVC, animated: true)
    }

    func openContactsWithUs() {
        let contactWithUsVC = ContactWithUsVC()
        isEnabledAnimationNavigation = true
        navigationController.pushViewController(contactWithUsVC, animated: true)
    }

    func openChangePhone() {
        let changePhoneVC = ChangePhoneVC()
        isEnabledAnimationNavigation = true
        navigationController.pushViewController(changePhoneVC, animated: true)
    }

    func openNotificationsSettings() {
        let notificationsSettingsVC = NotificationSettingsVC()
        isEnabledAnimationNavigation = true
        navigationController.pushViewController(notificationsSettingsVC, animated: true)
    }

    func popVC() {
        navigationController.popViewController(animated: true)
    }

    func openChangeInterests() {
        let changeAccountInterestsVC = SearchInterestsSetupProfileVC(
            selectedIntersests: AuthService.shared.currentUser.interestsList,
            mainButtonTitleType: .save
        )
        changeAccountInterestsVC.delegate = changeAccountDataVC?.infoUserVC
        isEnabledAnimationNavigation = true
        navigationController.pushViewController(changeAccountInterestsVC, animated: true)
    }
}
