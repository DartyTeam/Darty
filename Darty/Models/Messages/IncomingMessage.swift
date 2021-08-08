//
//  IncomingMessage.swift
//  Darty
//
//  Created by Руслан Садыков on 06.08.2021.
//

import Foundation
import MessageKit
import CoreLocation

class IncomingMessage {
    
    var messageCollectionView: MessagesViewController
    
    init(_collectionView: MessagesViewController) {
        self.messageCollectionView = _collectionView
    }
    
    // MARK: - CreateMessage
    func createMessage(localMessage: LocalMessage) -> MKMessage? {
        let mkMessage = MKMessage(message: localMessage)
        
        // multimedia messages
        
        return mkMessage
    }
}
