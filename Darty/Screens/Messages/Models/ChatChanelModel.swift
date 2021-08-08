//
//  ChatChanelModel.swift
//  Darty
//
//  Created by Руслан Садыков on 01.08.2021.
//

import FirebaseFirestore

struct ChatChanelModel {

    let id: String
    let name: String

    init(id: String, name: String) {
        self.id = id
        self.name = name
    }

    init?(document: QueryDocumentSnapshot) {
        let data = document.data()

        guard let name = data["name"] as? String else {
            return nil
        }

        id = document.documentID
        self.name = name
    }
}

extension ChatChanelModel {

    var representation: [String : Any] {
        var rep = ["name": name]
        rep["id"] = id
        return rep
    }

}

extension ChatChanelModel: Comparable {

    static func == (lhs: ChatChanelModel, rhs: ChatChanelModel) -> Bool {
        return lhs.id == rhs.id
    }

    static func < (lhs: ChatChanelModel, rhs: ChatChanelModel) -> Bool {
        return lhs.name < rhs.name
    }
}
