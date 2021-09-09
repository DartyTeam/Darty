//
//  AudioMessage.swift
//  Darty
//
//  Created by Руслан Садыков on 24.08.2021.
//

import MessageKit

class AudioMessage: NSObject, AudioItem {
    
    var url: URL
    var duration: Float
    var size: CGSize
    
    init(duration: Float) {
        self.url = URL(fileURLWithPath: "")
        self.size = CGSize(width: 160, height: 44)
        self.duration = duration
    }
}
