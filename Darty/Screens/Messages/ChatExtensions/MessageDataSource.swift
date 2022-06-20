//
//  MessageDataSource.swift
//  Darty
//
//  Created by Руслан Садыков on 06.08.2021.
//

import Foundation
import MessageKit
import UIKit

extension NewChatVC: MessagesDataSource {
    func currentSender() -> SenderType {
        return currentUser
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return mkMessages[indexPath.section]
    }
    
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return mkMessages.count
    }
    
    // MARK: - Cell top label
    func cellTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        if isTimeLabelVisible(at: indexPath) {
            let showLoadMore = (indexPath.section == 0) && (allLocalMessages.count > displayingMessagesCount)
            
            let text = showLoadMore ? "Потяните, чтобы загрузить больше" : MessageKitDateFormatter.shared.string(from: message.sentDate)
            let font: UIFont? = showLoadMore ? .subtitle : .textOnPlate

            return NSAttributedString(string: text, attributes: [.font: font, .foregroundColor: Colors.Text.secondary])
        }
        
        return nil
    }
    
    // MARK: - Message bottom label
    func messageBottomLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        var string = DateFormatter.HHmm.string(from: message.sentDate)
        if isFromCurrentSender(message: message) {
            let message = mkMessages[indexPath.section]
            let readStatusIcon: String
            switch message.status {
            case "read":
                readStatusIcon = "􀦧"
            case "sent":
                readStatusIcon = "􀆅"
            default:
                readStatusIcon = ""
            }
            string.append(contentsOf: " \(readStatusIcon)")
        }

        return NSAttributedString(
            string: string,
            attributes: [
                .font:  UIFont.textOnPlate,
                .foregroundColor: Colors.Text.secondary
            ]
        )
    }
}
