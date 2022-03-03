//
//  Coordinator.swift
//  Darty
//
//  Created by Руслан Садыков on 28.01.2022.
//

import UIKit

protocol Coordinator {
    var childCoordinators: [Coordinator] { get set }
    var navigationController: UINavigationController { get set }

    func start()
}
