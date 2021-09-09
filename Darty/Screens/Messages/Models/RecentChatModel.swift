//
//  RecentChatModel.swift
//  Darty
//
//  Created by Руслан Садыков on 28.06.2021.
//

import FirebaseFirestore

struct RecentChatModel: Hashable, Decodable {

    var id: String = UUID().uuidString
    var chatRoomId: String
    var senderId: String
    var senderName: String
    var receiverId: String
    var receiverName: String
    var lastMessageContent: String
    var date = Date()
    var memberIds: [String]
    var unreadCounter: Int
    var avatarLink: String
    
    var representation: [String: Any] {
        var rep = [String: Any]()
        rep["id"] = id
        rep["chatRoomId"] = chatRoomId
        rep["senderId"] = senderId
        rep["senderName"] = senderName
        rep["receiverId"] = receiverId
        rep["receiverName"] = receiverName
        rep["lastMessageContent"] = lastMessageContent
        rep["date"] = date
        rep["memberIds"] = memberIds
        rep["unreadCounter"] = unreadCounter
        rep["avatarLink"] = avatarLink
        
        return rep
    }
    
    init(chatRoomId: String, senderId: String, senderName: String, receiverId: String, receiverName: String, lastMessageContent: String, memberIds: [String], unreadCounter: Int, avatarLink: String) {
        self.chatRoomId = chatRoomId
        self.senderId = senderId
        self.senderName = senderName
        self.receiverId = receiverId
        self.receiverName = receiverName
        self.lastMessageContent = lastMessageContent
        self.memberIds = memberIds
        self.unreadCounter = unreadCounter
        self.avatarLink = avatarLink
    }
    
    init?(document: QueryDocumentSnapshot) {
        let data = document.data()
        guard let id = data["id"] as? String,
        let chatRoomId = data["chatRoomId"] as? String,
        let senderId = data["senderId"] as? String,
        let senderName = data["senderName"] as? String,
        let receiverId = data["receiverId"] as? String,
        let receiverName = data["receiverName"] as? String,
        let lastMessageContent = data["lastMessageContent"] as? String,
        let date = (data["date"] as? Timestamp)?.dateValue(),
        let memberIds = data["memberIds"] as? [String],
        let unreadCounter = data["unreadCounter"] as? Int,
        let avatarLink = data["avatarLink"] as? String
        else { return nil }
        
        self.id = id
        self.chatRoomId = chatRoomId
        self.senderId = senderId
        self.senderName = senderName
        self.receiverId = receiverId
        self.receiverName = receiverName
        self.lastMessageContent = lastMessageContent
        self.date = date
        self.memberIds = memberIds
        self.unreadCounter = unreadCounter
        self.avatarLink = avatarLink
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(receiverId)
    }
    
    static func == (lhs: RecentChatModel, rhs: RecentChatModel) -> Bool {
        return lhs.receiverId == rhs.receiverId
    }
    
    func contains(filter: String?) -> Bool {
        
        guard let filter = filter else { return true }
        if filter.isEmpty { return true }
        
        let lowercasedFilter = filter.lowercased()
        
        return receiverName.lowercased().contains(lowercasedFilter) || lastMessageContent.lowercased().contains(lowercasedFilter)
    }
}
