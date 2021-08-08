//
//  OutgoingMessage.swift
//  Darty
//
//  Created by Руслан Садыков on 06.08.2021.
//

import Foundation
import UIKit
//import FirebaseFirestoreSwift

class OutgoingMessage {
    
    class func send(chatId: String, text: String?, photo: UIImage?, video: String?, audio: String?, audioDuration: Float = 0.0, location: String?, memberIds: [String]) {
        
        let currentUser = AuthService.shared.currentUser!
        
        let message = LocalMessage()
        message.id = UUID().uuidString
        message.chatRoomId = chatId
        message.senderId = currentUser.id
        message.senderName = currentUser.username
        message.senderInitials = String(currentUser.username.first!)
        message.date = Date()
        message.status = GlobalConstants.kSENT
        
        if let text = text {
            sendTextMessage(message: message, text: text, memberIds: memberIds) { result in
                switch result {
                
                case .success():
                    print("Message \"\(message)\" saved local and send to firebase")
                case .failure(let error):
                    print("ERROR_LOG Error save local and send to firebase message \"\(message)\" :", error.localizedDescription)
                }
            }
            // send text massage
        }
        
        // TODO: Send push notification
        // TODO: Update resent
    }
    
    class func sendMessage(message: LocalMessage, memberIds: [String], completion: @escaping (Result<Void, Error>) -> Void) {
        RealmManager.shared.saveToRealm(message)
        
        for memberId in memberIds {
            FirestoreService.shared.addMessage(message, memberId: memberId, completion: completion)
        }
    }
}

func sendTextMessage(message: LocalMessage, text: String, memberIds: [String], completion: @escaping (Result<Void, Error>) -> Void) {
    message.message = text
    message.type = GlobalConstants.kTEXT
    
    OutgoingMessage.sendMessage(message: message, memberIds: memberIds, completion: completion)
}
