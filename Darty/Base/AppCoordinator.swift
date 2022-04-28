//
//  AppCoordinator.swift
//  Darty
//
//  Created by Руслан Садыков on 19.06.2021.
//

import UIKit
import Firebase

let getCurrentUserDataDispatchGroup = DispatchGroup()

final class AppCoordinator: NSObject {
    
    var window: UIWindow!
    var authCoordinator: AuthCoordinator?

    init(window: UIWindow?) {
        self.window = window!
        super.init()
        startScreenFlow()
    }

    private func startScreenFlow() {
        ConfigService.shared.getInterests()
        if let user = Auth.auth().currentUser {
            getCurrentUserDataDispatchGroup.enter()
            FirestoreService.shared.getUserData(user: user) { [weak self] (result) in
                switch result {
                case .success(let user):
                    ShortcutParser.shared.registerShortcuts(for: .authorized)
                    self?.openMainFlow(for: user)
                case .failure(_):
                    ShortcutParser.shared.registerShortcuts(for: .nonauthorized)
                    self?.openAuthFlow()
                }
                getCurrentUserDataDispatchGroup.leave()
            }
        } else {
            ShortcutParser.shared.registerShortcuts(for: .nonauthorized)
            openAuthFlow()
        }
    }

    func openAuthFlow() {
        ShortcutParser.shared.registerShortcuts(for: .nonauthorized)
        let navController = UINavigationController()
        authCoordinator = AuthCoordinator(navigationController: navController)
        authCoordinator?.delegate = self
        authCoordinator?.start()
        window.rootViewController = navController
        window.makeKeyAndVisible()
    }

    private(set) var tabBarController: TabBarController!

    private func openMainFlow(for user: UserModel) {
        AuthService.shared.currentUser = user
        ShortcutParser.shared.registerShortcuts(for: .authorized)
        tabBarController = TabBarController()
        tabBarController.modalPresentationStyle = .fullScreen
        window.rootViewController = tabBarController
        window.makeKeyAndVisible()
    }
}

extension AppCoordinator: AuthCoordinatorDelegate {
    func didAuthorized(with user: UserModel) {
        openMainFlow(for: user)
    }
}
