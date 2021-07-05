//
//  AppCoordinator.swift
//  Darty
//
//  Created by Руслан Садыков on 19.06.2021.
//

import UIKit
import Firebase

class AppCoordinator: NSObject {
    
    var window: UIWindow!

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
                    let tabBarController = TabBarController(currentUser: user)
                    tabBarController.modalPresentationStyle = .fullScreen
                    self?.window.rootViewController = tabBarController
                case .failure(_):
                    let navController = UINavigationController()
                    navController.setNavigationBarHidden(true, animated: false)
                    navController.pushViewController(LoginVC(), animated: false)
                    self?.window.rootViewController = navController
                }
            }
        } else {
            window.rootViewController = LoginVC()
        }
        
        window.makeKeyAndVisible()
    }
}
