//
//  VideoMessage.swift
//  Darty
//
//  Created by Руслан Садыков on 22.08.2021.
//

import Foundation
import MessageKit

class VideoMessage: NSObject, MediaItem {
    
    var url: URL?
    var image: UIImage?
    var placeholderImage: UIImage
    var size: CGSize
    
    init(url: URL?) {
        self.url = url
        self.placeholderImage = ((UIImage(systemName: "photo")?.withTintColor(.systemGray, renderingMode: .alwaysOriginal))?.withAlignmentRectInsets(UIEdgeInsets(top: -32, left: -32, bottom: -32, right: -32)))!
        self.size = CGSize(width: 240, height: 240)
    }
}
