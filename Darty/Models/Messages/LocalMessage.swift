//
//  LocalMessage.swift
//  Darty
//
//  Created by Руслан Садыков on 06.08.2021.
//

import Foundation
import RealmSwift

class LocalMessage: Object, Codable {
    
    @objc dynamic var id = ""
    @objc dynamic var chatRoomId = ""
    @objc dynamic var date = Date()
    @objc dynamic var senderName = ""
    @objc dynamic var senderId = ""
    @objc dynamic var senderInitials = ""
    @objc dynamic var readDate = Date()
    @objc dynamic var type = ""
    @objc dynamic var status = ""
    @objc dynamic var message = ""
    @objc dynamic var audioUrl = ""
    @objc dynamic var videoUrl = ""
    @objc dynamic var pictureUrl = ""
    @objc dynamic var latitude = 0.0
    @objc dynamic var longitude = 0.0
    @objc dynamic var audioDuration = 0.0
    
    override class func primaryKey() -> String? {
        return "id"
    }
    
    var representation: [String: Any] {
        var rep = [String: Any]()
        rep = ["id": id]
        rep["chatRoomId"] = chatRoomId
        rep["date"] = date
        rep["senderName"] = senderName
        rep["senderId"] = senderId
        rep["senderInitials"] = senderInitials
        rep["readDate"] = readDate
        rep["type"] = type
        rep["status"] = status
        rep["message"] = message
        rep["audioUrl"] = audioUrl
        rep["videoUrl"] = videoUrl
        rep["pictureUrl"] = pictureUrl
        rep["latitude"] = latitude
        rep["longitude"] = longitude
        rep["audioDuration"] = audioDuration
        return rep
    }
}
