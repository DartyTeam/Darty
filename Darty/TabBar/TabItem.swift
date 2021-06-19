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
    
    var viewController: UIViewController {
        switch self {
        case .parties:
            return PartiesVC()
        case .create:
            return CreateVC()
        case .messages:
            return MessagesVC()
        case .account:
            return AccountVC()
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
    
    var displayTitle: String {
        return self.rawValue.capitalized(with: nil)
    }
}
