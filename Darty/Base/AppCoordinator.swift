//
//  AppCoordinator.swift
//  Darty
//
//  Created by Руслан Садыков on 19.06.2021.
//

import UIKit

class AppCoordinator: NSObject {
    
    var window: UIWindow

    init(window: UIWindow?) {
        self.window = window!
        super.init()
        
        startScreenFlow()
    }
    
    func didFinishLaunchingWithOptions(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) {
        
    }

    private func startScreenFlow() {
        let navController = UINavigationController()
        navController.setNavigationBarHidden(true, animated: false)
        navController.pushViewController(LoginVC(), animated: false)
        
        self.window.rootViewController = navController
        self.window.makeKeyAndVisible()
    }
}
