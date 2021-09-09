//
//  UserModel.swift
//  Darty
//
//  Created by Руслан Садыков on 28.06.2021.
//

import Foundation
import FirebaseFirestore

struct UserModel: Hashable, Decodable {
    
    var username: String
    var phone: String
    var avatarStringURL: String
    var description: String
    var sex: Sex.RawValue?
    var birthday: Date
    var interestsList: [Int]
    var personalColor: String
    var city: String
    var country: String
    let id: String
    let pushId: String
    
    init(username: String, phone: String, avatarStringURL: String, description: String, sex: Sex.RawValue?, birthday: Date, interestsList: [Int], personalColor: String, id: String, pushId: String, city: String, country: String) {
        self.username = username
        self.phone = phone
        self.avatarStringURL = avatarStringURL
        self.description = description
        self.sex = sex
        self.birthday = birthday
        self.interestsList = interestsList
        self.personalColor = personalColor
        self.id = id
        self.pushId = pushId
        self.city = city
        self.country = country
    }
    
    init?(document: DocumentSnapshot) {
        guard let data = document.data() else { return nil }
        
        // Non optional values
        guard let username = data["username"] as? String,
        let phone = data["phone"] as? String,
        let avatarStringURL = data["avatarStringURL"] as? String,
        let description = data["description"] as? String,
        let birthday = (data["birthday"] as? Timestamp)?.dateValue(),
        let interestsList = data["interestsList"] as? [Int],
        let personalColor = data["personalColor"] as? String,
        let id = data["uid"] as? String,
        let pushId = data["pushId"] as? String,
        let city = data["city"] as? String,
        let country = data["country"] as? String
        else { return nil }
        
        // Optional value
        let sex = data["sex"] as? Sex.RawValue
        
        self.username = username
        self.phone = phone
        self.avatarStringURL = avatarStringURL
        self.description = description
        self.sex = sex
        self.birthday = birthday
        self.interestsList = interestsList
        self.personalColor = personalColor
        self.id = id
        self.pushId = pushId
        self.city = city
        self.country = country
    }
    
    var representation: [String: Any] {
        var rep = [String: Any]()
        rep = ["username": username]
        rep["sex"] = sex
        rep["phone"] = phone
        rep["avatarStringURL"] = avatarStringURL
        rep["description"] = description
        rep["birthday"] = birthday
        rep["interestsList"] = interestsList
        rep["personalColor"] = personalColor
        rep["uid"] = id
        rep["pushId"] = pushId
        rep["city"] = city
        rep["country"] = country
        return rep
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: UserModel, rhs: UserModel) -> Bool {
        return lhs.id == rhs.id
    }
    
    func contains(filter: String?) -> Bool {
        guard let filter = filter else { return true }
        if filter.isEmpty { return true }
        
        let lowercasedFilter = filter.lowercased()
        return username.lowercased().contains(lowercasedFilter)
    }
}
