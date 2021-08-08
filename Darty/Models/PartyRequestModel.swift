//
//  PartyRequestModel.swift
//  Darty
//
//  Created by Руслан Садыков on 28.07.2021.
//

import FirebaseFirestore

struct PartyRequestModel: Hashable, Decodable {
    var userId: String
    var message: String
    
    var representation: [String: Any] {
        var rep = ["userId": userId]
        rep["message"] = message
        return rep
    }
    
    init(userId: String, message: String) {
        self.userId = userId
        self.message = message
    }
    
    init?(document: QueryDocumentSnapshot) {
        let data = document.data()
        guard let userId = data["userId"] as? String,
              let message = data["message"] as? String
        else { return nil }
        
        self.userId = userId
        self.message = message
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(userId)
    }
    
    static func == (lhs: PartyRequestModel, rhs: PartyRequestModel) -> Bool {
        return lhs.userId == rhs.userId
    }
}
