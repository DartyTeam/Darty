//
//  UserDefaults + Extension.swift
//  Darty
//
//  Created by Руслан Садыков on 04.07.2021.
//

import Foundation

// MARK: – Custom objects extension
extension UserDefaults {
    func setCustomObject<T: Codable>(customObject: T, forKey: String) {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(customObject) {
            set(encoded, forKey: forKey)
        }
    }
    func getCustomObject<T: Codable>(forKey: String) -> T? {
        if let decoded  = object(forKey: forKey) as? Data{
            let decoder = JSONDecoder()
            if let decodedObject = try? decoder.decode(T.self, from: decoded) {
                return decodedObject
            }
        }
        return nil
    }
}

// MARK: – UserDefaultsKeys extension
extension UserDefaults {
    enum UserDefaultsKeys: String {
        case isPrevLaunched
    }
        
    var isPrevLaunched: Bool? {
        set { setCustomObject(customObject: newValue, forKey: UserDefaultsKeys.isPrevLaunched.rawValue) }
        get { return getCustomObject(forKey: UserDefaultsKeys.isPrevLaunched.rawValue) }
    }
}
