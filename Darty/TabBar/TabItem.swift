//
//  TabItem.swift
//  Darty
//
//  Created by Руслан Садыков on 19.06.2021.
//

import UIKit

enum TabItem: String, CaseIterable {

    case parties = "Вечеринки"
    case create = "Создать"
    case messages = "Сообщения"
    case account = "Аккаунт"

    // Cюда надо сделать список координаторов, вместо контроллеров
    var viewController: UIViewController {
        switch self {
        case .parties:
            return PartiesVC(currentUser: AuthService.shared.currentUser!)
        case .messages:
            return MessagesVC(currentUser: AuthService.shared.currentUser!)
        default:
            return UINavigationController()
        }
    }

    var coordinator: Coordinator {
        switch self {
        case .parties:
            return CreateCoordinator(navigationController: UINavigationController())
        case .create:
            return CreateCoordinator(navigationController: UINavigationController())
        case .messages:
            return CreateCoordinator(navigationController: UINavigationController())
        case .account:
            return AccountCoordinator(navigationController: UINavigationController())
        }
    }
    
    var icon: UIImage? {
        switch self {
        case .parties:
            return UIImage(named: "flame")
        case .create:
            return UIImage(named: "plus")
        case .messages:
            return UIImage(named: "message")
        case .account:
            return UIImage(named: "person")
        }
    }
    
    var selectedIcon: UIImage? {
        switch self {
        case .parties:
            return UIImage(named: "flame.fill")
        case .create:
            return UIImage(named: "plus.fill")
        case .messages:
            return UIImage(named: "message.fill")
        case .account:
            return UIImage(named: "person.fill")
        }
    }
    
    var color: UIColor {
        switch self {
        case .parties:
            return .systemOrange
        case .create:
            return .systemPurple
        case .messages:
            return .systemTeal
        case .account:
            return .systemIndigo
        }
    }

    var index: Int {
        switch self {
        case .parties:
            return 0
        case .create:
            return 1
        case .messages:
            return 2
        case .account:
            return 3
        }
    }
    
    var displayTitle: String {
        return self.rawValue.capitalized(with: nil)
    }
}
