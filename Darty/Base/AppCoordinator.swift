//
//  AppCoordinator.swift
//  Darty
//
//  Created by Руслан Садыков on 19.06.2021.
//

import UIKit
import Firebase

final class AppCoordinator: NSObject {
    
    var window: UIWindow!
    var authCoordinator: AuthCoordinator?

    init(window: UIWindow?) {
        self.window = window!
        super.init()
        startScreenFlow()
    }

    private func startScreenFlow() {
        if let user = Auth.auth().currentUser {
            FirestoreService.shared.getUserData(user: user) { [weak self] (result) in
                switch result {
                case .success(let user):
                    self?.openMainFlow(for: user)
                case .failure(_):
                    self?.openAuthFlow()
                }
            }
        } else {
            openAuthFlow()
        }
    }

    private func openAuthFlow() {
        let navController = UINavigationController()
        authCoordinator = AuthCoordinator(navigationController: navController)
        authCoordinator?.start()
        window.rootViewController = navController
        window.makeKeyAndVisible()
    }

    private func openMainFlow(for user: UserModel) {
        AuthService.shared.currentUser = user
        let tabBarController = TabBarController()
        tabBarController.modalPresentationStyle = .fullScreen
        window.rootViewController = tabBarController
        window.makeKeyAndVisible()
    }
}
