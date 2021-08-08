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
        
        if indexPath.section % 3 == 0 {
            
            // TODO: set different size for pull to reload
            return 30
        }
        
        return 0
    }
    
    // MARK: - Cell bottom label
    func cellBottomLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return isFromCurrentSender(message: message) ? 16 : 0
    }
    
    // MARK: - Message bottom label
    func messageBottomLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return indexPath.section != mkMessages.count - 1 ? 12 : 0
    }
    
    func configureAvatarView(_ avatarView: AvatarView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        
        let mkMessage = mkMessages[indexPath.section]
        avatarView.set(avatar: Avatar(image: nil, initials: mkMessage.senderInitials))
    }
}
