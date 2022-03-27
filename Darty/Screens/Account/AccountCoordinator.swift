//
//  AccountCoordinator.swift
//  Darty
//
//  Created by Руслан Садыков on 27.03.2022.
//

import UIKit

protocol AccountCoordinatorDelegate: AnyObject {
    func openAbout(userData: UserModel, preloadedUserImage: UIImage?)
    func openChangeInfo(preloadedUserImage: UIImage?)
    func openContactsWithUs()
    func openChangePhone()
}

protocol AccountChangeInfoCoordinatorDelegate: AnyObject {
    func openChangeInterests()
}

final class AccountCoordinator: Coordinator {
    var childCoordinators = [Coordinator]()
    var navigationController: UINavigationController

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
        let aboutUserVC = AboutUserVC(userData: userData, preloadedUserImage: preloadedUserImage)
        isEnabledAnimationNavigation = false
        navigationController.pushViewController(aboutUserVC, animated: true)
    }

    func openChangeInfo(preloadedUserImage: UIImage?) {
        let changeAccountDataVC = ChangeAccountDataVC(preloadedUserImage: preloadedUserImage, coordinatorDelegate: self)
        isEnabledAnimationNavigation = false
        navigationController.pushViewController(changeAccountDataVC, animated: true)
    }

    func openContactsWithUs() {
        let contactWithUsVC = ContactWithUsVC()
        isEnabledAnimationNavigation = false
        navigationController.pushViewController(contactWithUsVC, animated: true)
    }

    func openChangePhone() {
        let changePhoneVC = ChangePhoneVC()
        isEnabledAnimationNavigation = false
        navigationController.pushViewController(changePhoneVC, animated: true)
    }
}

extension AccountCoordinator: AccountChangeInfoCoordinatorDelegate {
    func openChangeInterests() {
        let changeAccountInterestsVC = SearchInterestsSetupProfileVC(selectedIntersests: AuthService.shared.currentUser.interestsList)
        print("asdokasdopkasdopaksdopaskd")
        isEnabledAnimationNavigation = true
        navigationController.pushViewController(changeAccountInterestsVC, animated: true)
    }
}
