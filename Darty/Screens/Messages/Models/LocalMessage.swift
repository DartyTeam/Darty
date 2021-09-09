//
//  LocalMessage.swift
//  Darty
//
//  Created by Руслан Садыков on 06.08.2021.
//

import Foundation
import RealmSwift
import FirebaseFirestore

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
    
    override init() {
        super.init()
    }
    
    init?(document: QueryDocumentSnapshot) {
        let data = document.data()
        
        guard let id = data["id"] as? String,
              let chatRoomId = data["chatRoomId"] as? String,
              let date = (data["date"] as? Timestamp)?.dateValue(),
              let senderName = data["senderName"] as? String,
              let senderId = data["senderId"] as? String,
              let senderInitials = data["senderInitials"] as? String,
              let readDate = (data["readDate"] as? Timestamp)?.dateValue(),
              let type = data["type"] as? String,
              let status = data["status"] as? String,
              let message = data["message"] as? String,
              let audioUrl = data["audioUrl"] as? String,
              let videoUrl = data["videoUrl"] as? String,
              let pictureUrl = data["pictureUrl"] as? String,
              let latitude = data["latitude"] as? Double,
              let longitude = data["longitude"] as? Double,
              let audioDuration = data["audioDuration"] as? Double
        else { return nil }
        
        self.id = id
        self.chatRoomId = chatRoomId
        self.date = date
        self.senderName = senderName
        self.senderId = senderId
        self.senderInitials = senderInitials
        self.readDate = readDate
        self.type = type
        self.status = status
        self.message = message
        self.audioUrl = audioUrl
        self.videoUrl = videoUrl
        self.pictureUrl = pictureUrl
        self.latitude = latitude
        self.longitude = longitude
        self.audioDuration = audioDuration
    }
}
