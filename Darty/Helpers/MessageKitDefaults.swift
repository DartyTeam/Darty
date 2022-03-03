//
//  MessageKitDefaults.swift
//  Darty
//
//  Created by Руслан Садыков on 06.08.2021.
//

import Foundation
import UIKit
import MessageKit

struct MKSender: SenderType, Equatable {
    var senderId: String
    var displayName: String
}

enum MessageDefaults {
    // Bubble
    static let bubbleColorOutgoig = UIColor.systemTeal
    static let bubbleColorIncoming = UIColor.systemGroupedBackground
}
