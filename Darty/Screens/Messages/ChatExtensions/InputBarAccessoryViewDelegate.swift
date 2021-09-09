//
//  InputBarAccessoryViewDelegate.swift
//  Darty
//
//  Created by Руслан Садыков on 06.08.2021.
//

import Foundation
import InputBarAccessoryView

extension NewChatVC: InputBarAccessoryViewDelegate {
    
    func inputBar(_ inputBar: InputBarAccessoryView, textViewTextDidChangeTo text: String) {
        if !text.isEmpty {
            typingIndicatorUpdate()
        }
        
        if messageInputBar.sendButton.isAnimating == false {
            updateMicButtonStatus(show: text.isEmpty)
        }
    }
    
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        for component in inputBar.inputTextView.components {
            if let text = component as? String {
                
                messageSend(text: text, photo: nil, video: nil, audio: nil, location: nil)
            }
        }
        
        messageInputBar.inputTextView.text = ""
        messageInputBar.invalidatePlugins()
    }
}
