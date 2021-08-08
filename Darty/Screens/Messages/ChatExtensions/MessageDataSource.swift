//
//  MessageDataSource.swift
//  Darty
//
//  Created by Руслан Садыков on 06.08.2021.
//

import Foundation
import MessageKit

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
        if indexPath.section % 3 == 0 {
            
            let showLoadMore = false
            
            let text = showLoadMore ? "Потяните, чтобы загрузить больше" : MessageKitDateFormatter.shared.string(from: message.sentDate)
            let font = showLoadMore ? UIFont.sfProRounded(ofSize: 14, weight: .bold) : UIFont.sfProRounded(ofSize: 10, weight: .semibold)
            
            let color = showLoadMore ? UIColor.systemTeal : UIColor.darkGray
            
            return NSAttributedString(string: text, attributes: [.font : font, .foregroundColor: color])
        }
        
        return nil
    }
    
    // Mark: - Cell bottom label
    func cellBottomLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        if isFromCurrentSender(message: message) {
            let message = mkMessages[indexPath.section]
            let status = indexPath.section == mkMessages.count - 1 ? message.status + " " + DateFormatter.HHmm.string(from: message.readDate) : ""
            
            return NSAttributedString(string: status, attributes: [.font : UIFont.sfProRounded(ofSize: 10, weight: .semibold), .foregroundColor : UIColor.darkGray])
        }
        
        return nil
    }
    
    // MARK: - Message bottom label
    func messageBottomLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        if indexPath.section != mkMessages.count - 1 {
            return NSAttributedString(string: DateFormatter.HHmm.string(from: message.sentDate), attributes: [.font : UIFont.sfProRounded(ofSize: 10, weight: .bold), .foregroundColor : UIColor.darkGray])
        }
        
        return nil
    }
}
