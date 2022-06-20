//
//  MessageLayoutDelegate.swift
//  Darty
//
//  Created by Руслан Садыков on 06.08.2021.
//

import Foundation
import MessageKit

extension NewChatVC: MessagesLayoutDelegate {
    
    // MARK: - Cell top label
    func cellTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        if isTimeLabelVisible(at: indexPath) {
            if (indexPath.section == 0) && (allLocalMessages.count > displayingMessagesCount) {
                return 40
            }
            return 30
        }
        return 0
    }
    
    func messageTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
//        if isFromCurrentSender(message: message) {
//            return !isPreviousMessageSameSender(at: indexPath) ? 20 : 0
//        } else {
//            return !isPreviousMessageSameSender(at: indexPath) ? 20 : 0
//        }
        return 0
    }

    // MARK: - Message bottom label
    // Лейбл с временем отправки сообщения
    func messageBottomLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        let minimumHeightNeededForShowingLabel: CGFloat = 13
        let spacingBetweemMessageAndTimeLabel: CGFloat = 4
        return minimumHeightNeededForShowingLabel + spacingBetweemMessageAndTimeLabel
    }

    func footerViewSize(for section: Int, in messagesCollectionView: MessagesCollectionView) -> CGSize {
        return CGSize(width: 0, height: 0)
    }

    // Настройка отображения аватаров перед баблом сообщения
    //    func configureAvatarView(_ avatarView: AvatarView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
    //        let avatar = Avatar(image: recipientImage, initials: "\(recipientData.username.first ?? " ")")
    //        avatarView.set(avatar: avatar)
    //        avatarView.isHidden = isNextMessageSameSender(at: indexPath)
    //        avatarView.isHidden = true
    //    }
}
