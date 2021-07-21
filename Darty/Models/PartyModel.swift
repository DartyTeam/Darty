//
//  PartyModel.swift
//  Darty
//
//  Created by Руслан Садыков on 28.06.2021.
//

import Foundation
import FirebaseFirestore

enum PriceType: String, CaseIterable {
    
    case free = "Бесплатно 􀎸"
    case money = "Деньги 􀭿"
    case another = "Другое 􀍣"
    
    var description: String {
        get {
            switch self {
            case .free:
                return "Бесплатно 􀎸"
            case .money:
                return "Деньги 􀭿"
            case .another:
                return "Другое 􀍣"
            }
        }
    }
    
    static func getPriceType(priceType: String) -> PriceType {
        switch priceType {
        case "Бесплатно 􀎸":
            return .free
        case "Деньги 􀭿":
            return .money
        case "Другое 􀍣":
            return .another
        default:
            return .free
        }
    }
}

//􀻐

extension PriceType: Codable {
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawValue = try container.decode(String.self)
        self = PriceType.getPriceType(priceType: rawValue)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(self.description)
    }
}

enum PartyType: String, CaseIterable {
    case music = "Музыкальная 􀫀"
    case dance = "Танцевальная 􀳾􀝢􀝻"
    case hangout = "Вписка 􀆿"
    case poem = "Поэтическая 􀉇"
    case art = "Творческая 􀝥"
    case celebrate = "Праздничная 􀳇"
    case game = "Игровая 􀛸"
    case science = "Научная 􀬗"
    case it = "Домашний хакатон 􀙚"
    case cinema = "Домашний кинотеатр 􀪃"
    case other = "Особая тематика 􀣳"
    
    var description: String {
        get {
            switch self {
            case .music:
                return "Музыкальная 􀫀"
            case .dance:
                return "Танцевальная 􀳾􀝢􀝻"
            case .hangout:
                return "Вписка 􀆿"
            case .poem:
                return "Поэтическая 􀉇"
            case .art:
                return "Творческая 􀝥"
            case .celebrate:
                return "Праздничная 􀳇"
            case .game:
                return "Игровая 􀛸"
            case .science:
                return "Научная 􀬗"
            case .it:
                return "Домашний хакатон 􀙚"
            case .cinema:
                return "Домашний кинотеатр 􀪃"
            case .other:
                return "Особая тематика 􀣳"
            }
        }
    }
    
    static func getPartyType(partyType: String) -> PartyType {
        switch partyType {
        case "Музыкальная 􀫀":
            return .music
        case "Танцевальная 􀳾􀝢􀝻":
            return .dance
        case "Вписка 􀆿":
            return .hangout
        case "Поэтическая 􀉇":
            return .poem
        case "Творческая 􀝥":
            return .art
        case "Праздничная 􀳇":
            return .celebrate
        case "Игровая 􀛸":
            return .game
        case "Научная 􀬗":
            return .science
        case "Домашний хакатон 􀙚":
            return .it
        case "Домашний кинотеатр 􀪃":
            return .cinema
        case "Особая тематика 􀣳":
            return .other
        default:
            return .other
        }
    }
}

extension PartyType: Codable {
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawValue = try container.decode(String.self)
        self = PartyType.getPartyType(partyType: rawValue)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(self.description)
    }
}

struct PartyModel: Hashable, Decodable {
    
    var id: String
    var city: String
    var location: String
    var userId: String
    var imageUrlStrings: [String]
    var type: PartyType.RawValue
    var maximumPeople: Int
    var currentPeople: Int
    var date: Date
    var startTime: Date
    var endTime: Date?
    var name: String
    var priceType: PriceType.RawValue
    var price: String
    var description: String
    var minAge: Int
    
    init(city: String, location: String, userId: String, imageUrlStrings: [String], type: PartyType.RawValue, maximumPeople: Int, currentPeople: Int, id: String, date: Date, startTime: Date, endTime: Date?, name: String, price: String, priceType: PriceType.RawValue, description: String, minAge: Int) {
        self.city = city
        self.location = location
        self.userId = userId
        self.imageUrlStrings = imageUrlStrings
        self.type = type
        self.maximumPeople = maximumPeople
        self.currentPeople = currentPeople
        self.id = id
        self.date = date
        self.startTime = startTime
        self.endTime = endTime
        self.name = name
        self.price = price
        self.description = description
        self.minAge = minAge
        self.priceType = priceType
    }
    
    init?(document: DocumentSnapshot) {
        guard let data = document.data() else { return nil }
        guard let city = data["city"] as? String,
              let location = data["location"] as? String,
              let userId = data["userId"] as? String,
              let imageUrlStrings = data["imageUrlStrings"] as? [String],
              let type = data["type"] as? PartyType.RawValue,
              let maximumPeople = data["maximumPeople"] as? Int,
              let currentPeople = data["currentPeople"] as? Int,
              let date = (data["date"] as? Timestamp)?.dateValue(),
              let startTime = (data["startTime"] as? Timestamp)?.dateValue(),
              let endTime = (data["endTime"] as? Timestamp)?.dateValue(),
              let name = data["name"] as? String,
              let price = data["price"] as? String,
              let priceType = data["priceType"] as? PriceType.RawValue,
              let description = data["description"] as? String,
              let id = data["uid"] as? String,
              let minAge = data["minAge"] as? Int
        
        else { return nil }
        
        self.city = city
        self.location = location
        self.userId = userId
        self.imageUrlStrings = imageUrlStrings
        self.type = type
        self.maximumPeople = maximumPeople
        self.currentPeople = currentPeople
        self.date = date
        self.startTime = startTime
        self.endTime = endTime
        self.name = name
        self.price = price
        self.description = description
        self.id = id
        self.minAge = minAge
        self.priceType = priceType
    }
    
    var representation: [String: Any] {
        var rep = [String: Any]()
        rep = ["location": location]
        rep["city"] = city
        rep["userId"] = userId
        rep["imageUrlStrings"] = imageUrlStrings
        rep["type"] = type
        rep["maximumPeople"] = maximumPeople
        rep["currentPeople"] = currentPeople
        rep["date"] = date
        rep["startTime"] = startTime
        rep["endTime"] = endTime
        rep["name"] = name
        rep["price"] = price
        rep["priceType"] = priceType
        rep["description"] = description
        rep["uid"] = id
        rep["minAge"] = minAge
        return rep
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: PartyModel, rhs: PartyModel) -> Bool {
        return lhs.id == rhs.id
    }
    
    func contains(filter: String?) -> Bool {
        
        guard let filter = filter else { return true }
        if filter.isEmpty { return true }
        
        let lowercasedFilter = filter.lowercased()
        
        return name.lowercased().contains(lowercasedFilter) || type.lowercased().contains(lowercasedFilter)
    }
}
