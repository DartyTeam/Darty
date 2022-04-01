//
//  DeeplinkManager.swift
//  Darty
//
//  Created by Руслан Садыков on 30.03.2022.
//

import Foundation
import UIKit
import SPAlert

enum DeeplinkType {
    enum Messages {
        case root
        case details(id: String)
    }
    case messages(Messages)
    case myParties
    case party(id: String)
    case user(id: String)
    case aboutMe
}

final class DeeplinkManager {
    static let shared = DeeplinkManager()

    private init() {}

    private var deeplinkType: DeeplinkType?

    func checkDeepLink(with appCoordinator: AppCoordinator) {
        guard let deeplinkType = deeplinkType else { return }
        DeeplinkNavigator.shared.proceedToDeeplink(deeplinkType, appCoordinator: appCoordinator)
        // reset deeplink after handling
        self.deeplinkType = nil
    }

    @discardableResult
    func handleShortcut(item: UIApplicationShortcutItem) -> Bool {
        deeplinkType = ShortcutParser.shared.handleShortcut(item)
        return deeplinkType != nil
    }

    @discardableResult
    func handleDeeplink(url: URL) -> Bool {
        deeplinkType = DeeplinkParser.shared.parseDeepLink(url)
        return deeplinkType != nil
    }

    func handleRemoteNotification(_ notification: [AnyHashable: Any]) {
        deeplinkType = NotificationParser.shared.handleNotification(notification)
    }
}

final class DeeplinkNavigator {
    static let shared = DeeplinkNavigator()
    private init() {}

    func proceedToDeeplink(_ type: DeeplinkType, appCoordinator: AppCoordinator) {
        getCurrentUserDataDispatchGroup.notify(queue: .main) {
            switch type {
            case .messages(.root):
                appCoordinator.tabBarController.changeSelectedIndexFor(tabItem: .messages)
            case .messages(.details(let id)):
                appCoordinator.tabBarController.changeSelectedIndexFor(tabItem: .messages)
                let messagesVC = appCoordinator.tabBarController.getControllerFor(tabItem: .messages) as? MessagesVC
                FirestoreService.shared.getRecentChat(by: id) { result in
                    switch result {
                    case .success(let recentChat):
                        messagesVC?.navigationController?.popToRootViewController(animated: true)
                        messagesVC?.open(chat: recentChat)
                    case .failure(let error):
                        SPAlert.present(title: error.localizedDescription, preset: .error)
                        print("ERROR_LOG Erro get recent chat by id \(id): ", error.localizedDescription)
                    }
                }
            case .user(let id):
                appCoordinator.tabBarController.changeSelectedIndexFor(tabItem: .messages)
                let messagesVC = appCoordinator.tabBarController.getControllerFor(tabItem: .messages) as? MessagesVC
                FirestoreService.shared.getUser(by: id) { result in
                    switch result {
                    case .success(let user):
                        let aboutUserVC = AboutUserVC(userData: user)
                        messagesVC?.navigationController?.pushViewController(aboutUserVC, animated: true)
                    case .failure(let error):
                        SPAlert.present(title: error.localizedDescription, preset: .error)
                        print("ERROR_LOG Error get userdata by id \(id): ", error.localizedDescription)
                    }
                }
            case .aboutMe:
                appCoordinator.tabBarController.changeSelectedIndexFor(tabItem: .account)
                let accountVC = appCoordinator.tabBarController.getControllerFor(tabItem: .account) as? AccountVC
                guard let userData = AuthService.shared.currentUser else {
                    print("ERROR_LOG Error get user data from AuthService.shared.currentUser")
                    return
                }
                accountVC?.delegate?.openAbout(userData: userData, preloadedUserImage: nil)
            case .myParties:
                appCoordinator.tabBarController.changeSelectedIndexFor(tabItem: .parties)
                let partiesVC = appCoordinator.tabBarController.getControllerFor(tabItem: .parties) as? PartiesVC
                partiesVC?.changeSelectedPartyList(type: .my)
            case .party(let id):
                appCoordinator.tabBarController.changeSelectedIndexFor(tabItem: .parties)
                let partiesVC = appCoordinator.tabBarController.getControllerFor(tabItem: .parties) as? PartiesVC
                FirestoreService.shared.getPartyBy(uid: id) { result in
                    switch result {
                    case .success(let party):
#warning("Добавить проверку типа вечеринки для открытия")
                        let aboutPartyVC = AboutPartyVC(party: party, type: .search)
                        partiesVC?.navigationController?.pushViewController(aboutPartyVC, animated: true)
                    case .failure(let error):
                        SPAlert.present(title: error.localizedDescription, preset: .error)
                        print("ERROR_LOG Error get party by id \(id): ", error.localizedDescription)
                    }
                }
            }
        }
    }
}

enum ProfileType {
    case authorized
    case nonauthorized
}

final class ShortcutParser {
    static let shared = ShortcutParser()
    private init() {}

    enum ShortcutKey: String {
        case myParties = "Ruslan-Sadykov.Darty.myParties"
        case aboutMe = "Ruslan-Sadykov.Darty.aboutMe"
        case messages = "Ruslan-Sadykov.Darty.messages"
    }

    func registerShortcuts(for profileType: ProfileType) {
        switch profileType {
        case .authorized:
            let messageIcon = UIApplicationShortcutIcon(type: .message)
            let messageShortcutItem = UIApplicationShortcutItem(
                type: ShortcutKey.messages.rawValue,
                localizedTitle: "Сообщения",
                localizedSubtitle: nil,
                icon: messageIcon,
                userInfo: nil
            )
            let myPartyesIcon = UIApplicationShortcutIcon(systemImageName: "flame")
            let myPartyesShortcutItem = UIApplicationShortcutItem(
                type: ShortcutKey.myParties.rawValue,
                localizedTitle: "Мои вечеринки",
                localizedSubtitle: nil,
                icon: myPartyesIcon,
                userInfo: nil
            )
            let aboutMeIcon = UIApplicationShortcutIcon(type: .contact)
            let aboutMeShortcutItem = UIApplicationShortcutItem(
                type: ShortcutKey.aboutMe.rawValue,
                localizedTitle: "Обо мне",
                localizedSubtitle: nil,
                icon: aboutMeIcon,
                userInfo: nil
            )
            UIApplication.shared.shortcutItems = [messageShortcutItem, myPartyesShortcutItem, aboutMeShortcutItem]
        case .nonauthorized:
            UIApplication.shared.shortcutItems?.removeAll()
        }
    }

    func handleShortcut(_ shortcut: UIApplicationShortcutItem) -> DeeplinkType? {
        switch shortcut.type {
        case ShortcutKey.myParties.rawValue:
            return .myParties
        case ShortcutKey.aboutMe.rawValue:
            return .aboutMe
        case ShortcutKey.messages.rawValue:
            return .messages(.root)
        default:
            return nil
        }
    }
}

final class DeeplinkParser {
    static let shared = DeeplinkParser()
    private init() { }

    func parseDeepLink(_ url: URL) -> DeeplinkType? {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: true),
              let host = components.host
        else {
            return nil
        }
        var pathComponents = components.path.components(separatedBy: "/")
        // the first component is empty
        pathComponents.removeFirst()
        switch host {
        case "message":
            if let messageId = pathComponents.first {
                return DeeplinkType.messages(.details(id: messageId))
            }
        case "messages":
            return DeeplinkType.messages(.root)
        case "party":
            if let partyId = pathComponents.first {
                return DeeplinkType.party(id: partyId)
            }
        case "user":
            if let userId = pathComponents.first {
                return DeeplinkType.user(id: userId)
            }
        default:
            break
        }
        return nil
    }
}

final class NotificationParser {
    static let shared = NotificationParser()
    private init() { }

    func handleNotification(_ userInfo: [AnyHashable : Any]) -> DeeplinkType? {
        guard let data = userInfo["data"] as? [String: Any],
              let chatId = data["chatId"] as? String
        else {
            return nil
        }
        return DeeplinkType.messages(.details(id: chatId))
    }
}
