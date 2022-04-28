//
//  InterestModel.swift
//  Darty
//
//  Created by Руслан Садыков on 19.04.2022.
//

import Foundation

struct InterestsModel: Codable {
    let interests: [InterestModel]
}

struct InterestModel: Codable {
    let id: Int
    let title: String
    let emoji: String
}
