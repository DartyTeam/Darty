//
//  ShareUserHelper.swift
//  Darty
//
//  Created by Руслан Садыков on 17.04.2022.
//

import UIKit
import SPAlert

enum ShareHelper {
    static func share(user: UserModel, from vc: UIViewController) {
        let text = "Смотри в Darty darty://user/\(user.id): \(user.username), \(user.city), \(user.birthday.age())"
        let items: [Any] = [text]
        let ac = UIActivityViewController(activityItems: items, applicationActivities: nil)
        ac.excludedActivityTypes = [.addToReadingList, .airDrop, .assignToContact, .markupAsPDF, .openInIBooks, .saveToCameraRoll]
        ac.completionWithItemsHandler = { activity, completed, items, error in
            guard completed else { return }
            switch activity {
            case .some(.copyToPasteboard):
                SPAlert.present(
                    title: "Информация о пользователе скопирована в буфер обмена",
                    preset: .custom(UIImage(.doc.onClipboardFill)),
                    haptic: .success
                )
            case .some(_):
                SPAlert.present(title: "Спасибо что поделились", preset: .heart)
            case .none:
                break
            }
        }
        vc.navigationController?.present(ac, animated: true)
    }

    static func share(party: PartyModel, approvedUsersCount: Int, from vc: UIViewController) {
        var endTimeString = ""
        if let endTime = party.endTime {
            endTimeString = DateFormatter.HHmm.string(from: endTime)
        }
        let text = "Приходи на вечеринку darty://party/\(party.id) \n\"\(party.name)\"!\n\(party.description)\nДата: \(DateFormatter.ddMMMM.string(from: party.date))\nВремя: \(DateFormatter.HHmm.string(from: party.startTime)) \(endTimeString.isEmpty ? "" : "до \(endTimeString)")\nТематика: \(party.type.dropLast())\nМесто: \(party.address)\nПриглашено \(approvedUsersCount) из \(party.maxGuests)\nДля людей старше \(party.minAge)"
        let items: [Any] = [text]
        let ac = UIActivityViewController(activityItems: items, applicationActivities: nil)
        ac.excludedActivityTypes = [.addToReadingList, .airDrop, .assignToContact, .markupAsPDF, .openInIBooks, .saveToCameraRoll]
        ac.completionWithItemsHandler = { activity, completed, items, error in
            guard completed else { return }
            switch activity {
            case .some(.copyToPasteboard):
                SPAlert.present(
                    title: "Информация о вечеринке скопирована в буфер обмена",
                    preset: .custom(UIImage(.doc.onClipboardFill)),
                    haptic: .success
                )
            case .some(_):
                SPAlert.present(title: "Спасибо что поделились вечеринкой", preset: .heart)
            case .none:
                break
            }
        }
        vc.navigationController?.present(ac, animated: true)
    }
}
