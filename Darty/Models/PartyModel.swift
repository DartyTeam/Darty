//
//  PartyModel.swift
//  Darty
//
//  Created by Руслан Садыков on 28.06.2021.
//

import Foundation
import FirebaseFirestore

enum PriceType: String, Codable, CaseIterable {
    case free
    case money
    case another

    var index: Int {
        switch self {
        case .free:
            return 0
        case .money:
            return 1
        case .another:
            return 2
        }
    }

    static var allCasesForSegmentedControl: [String] {
        var array = [String]()
        for item in self.allCases {
            array.append(item.description)
        }
        return array
    }

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
}

enum PartyType: String, Codable, CaseIterable {
    case music
    case dance
    case hangout
    case poem
    case art
    case celebrate
    case game
    case science
    case it
    case cinema
    case other

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
}

enum PartyModelKeys {
    static let id = "id"
    static let city = "city"
    static let location = "location"
    static let address = "address"
    static let userId = "userId"
    static let imageUrlStrings = "imageUrlStrings"
    static let type = "type"
    static let maxGuests = "maxGuests"
    static let curGuests = "curGuests"
    static let date = "date"
    static let startTime = "startTime"
    static let endTime = "endTime"
    static let name = "name"
    static let priceType = "priceType"
    static let moneyPrice = "moneyPrice"
    static let anotherPrice = "anotherPrice"
    static let description = "description"
    static let minAge = "minAge"
    static let isCanceled = "isCanceled"
    static let uid = "uid"
}

struct PartyModel: Hashable, Decodable {
    var id: String
    var city: String
    var location: GeoPoint
    var address: String
    var userId: String
    var imageUrlStrings: [String]
    var type: PartyType
    var maxGuests: Int
    var curGuests: Int
    var date: Date
    var startTime: Date
    var endTime: Date?
    var name: String
    var priceType: PriceType
    var moneyPrice: Int?
    var anotherPrice: String?
    var description: String
    var minAge: Int
    var isCanceled: Bool
    
    init(city: String,
         location: GeoPoint,
         address: String,
         userId: String,
         imageUrlStrings: [String],
         type: PartyType,
         maxGuests: Int,
         curGuests: Int,
         id: String,
         date: Date,
         startTime: Date,
         endTime: Date?,
         name: String,
         moneyPrice: Int?,
         anotherPrice: String?,
         priceType: PriceType,
         description: String,
         minAge: Int,
         isCanceled: Bool = false) {
        self.city = city
        self.location = location
        self.address = address
        self.userId = userId
        self.imageUrlStrings = imageUrlStrings
        self.type = type
        self.maxGuests = maxGuests
        self.curGuests = curGuests
        self.id = id
        self.date = date
        self.startTime = startTime
        self.endTime = endTime
        self.name = name
        self.moneyPrice = moneyPrice
        self.anotherPrice = anotherPrice
        self.description = description
        self.minAge = minAge
        self.priceType = priceType
        self.isCanceled = isCanceled
    }
    
    init?(document: DocumentSnapshot) {
        // Non optional values
        guard
            let data = document.data()
        else {
            return nil
        }
        guard
            let city = data[PartyModelKeys.city] as? String,
            let location = data[PartyModelKeys.location] as? GeoPoint,
            let address = data[PartyModelKeys.address] as? String,
            let userId = data[PartyModelKeys.userId] as? String,
            let imageUrlStrings = data[PartyModelKeys.imageUrlStrings] as? [String],
            let typeString = data[PartyModelKeys.type] as? String,
                let type = PartyType(rawValue: typeString),
            let maxGuests = data[PartyModelKeys.maxGuests] as? Int,
            let curGuests = data[PartyModelKeys.curGuests] as? Int,
            let date = (data[PartyModelKeys.date] as? Timestamp)?.dateValue(),
            let startTime = (data[PartyModelKeys.startTime] as? Timestamp)?.dateValue(),
            let name = data[PartyModelKeys.name] as? String,
            let priceTypeString = data[PartyModelKeys.priceType] as? String,
                let priceType = PriceType(rawValue: priceTypeString),
            let description = data[PartyModelKeys.description] as? String,
            let id = data[PartyModelKeys.uid] as? String,
            let minAge = data[PartyModelKeys.minAge] as? Int,
            let isCanceled = data[PartyModelKeys.isCanceled] as? Bool
        else {
            return nil
        }
        
        // Optional values
        let endTime = (data[PartyModelKeys.endTime] as? Timestamp)?.dateValue()
        let moneyPrice = data[PartyModelKeys.moneyPrice] as? Int
        let anotherPrice = data[PartyModelKeys.anotherPrice] as? String
            
        self.city = city
        self.location = location
        self.address = address
        self.userId = userId
        self.imageUrlStrings = imageUrlStrings
        self.type = type
        self.maxGuests = maxGuests
        self.curGuests = curGuests
        self.date = date
        self.startTime = startTime
        self.endTime = endTime
        self.name = name
        self.moneyPrice = moneyPrice
        self.anotherPrice = anotherPrice
        self.description = description
        self.id = id
        self.minAge = minAge
        self.priceType = priceType
        self.isCanceled = isCanceled
    }
    
    var representation: [String: Any] {
        var rep = [String: Any]()
        rep = [PartyModelKeys.location: location]
        rep[PartyModelKeys.city] = city
        rep[PartyModelKeys.address] = address
        rep[PartyModelKeys.userId] = userId
        rep[PartyModelKeys.imageUrlStrings] = imageUrlStrings
        rep[PartyModelKeys.type] = type.rawValue
        rep[PartyModelKeys.maxGuests] = maxGuests
        rep[PartyModelKeys.curGuests] = curGuests
        rep[PartyModelKeys.date] = date
        rep[PartyModelKeys.startTime] = startTime
        rep[PartyModelKeys.endTime] = endTime
        rep[PartyModelKeys.name] = name
        rep[PartyModelKeys.moneyPrice] = moneyPrice
        rep[PartyModelKeys.anotherPrice] = anotherPrice
        rep[PartyModelKeys.priceType] = priceType.rawValue
        rep[PartyModelKeys.description] = description
        rep[PartyModelKeys.uid] = id
        rep[PartyModelKeys.minAge] = minAge
        rep[PartyModelKeys.isCanceled] = isCanceled
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
        return name.lowercased().contains(lowercasedFilter) || type.rawValue.lowercased().contains(lowercasedFilter)
    }
}

struct MyPartyIdModel: Decodable {

    var uid: String

    init?(document: DocumentSnapshot) {
        guard let data = document.data(),
              let uid = data["uid"] as? String
        else {
            return nil
        }

        self.uid = uid
    }
}
