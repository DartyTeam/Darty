//
//  GeoPoint.swift
//  Darty
//
//  Created by Руслан Садыков on 01.08.2021.
//

import FirebaseFirestore

fileprivate protocol CodableGeoPoint: Codable {
    var latitude: Double { get }
    var longitude: Double { get }

    init(latitude: Double, longitude: Double)
}

fileprivate enum GeoPointKeys: String, CodingKey {
    case latitude
    case longitude
}

extension CodableGeoPoint {
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: GeoPointKeys.self)
        let latitude = try container.decode(Double.self, forKey: .latitude)
        let longitude = try container.decode(Double.self, forKey: .longitude)
        self.init(latitude: latitude, longitude: longitude)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: GeoPointKeys.self)
        try container.encode(latitude, forKey: .latitude)
        try container.encode(longitude, forKey: .longitude)
    }
}

extension GeoPoint: CodableGeoPoint {}
