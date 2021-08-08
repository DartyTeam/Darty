//
//  RealmManager.swift
//  Darty
//
//  Created by Руслан Садыков on 06.08.2021.
//

import Foundation
import RealmSwift

class RealmManager {
    
    static let shared = RealmManager()
    let realm = try! Realm()
    
    private init() { }
    
    func saveToRealm<T: Object>(_ object: T) {
        do {
            try realm.write({
                realm.add(object, update: .all)
            })
        } catch {
            print("ERROR_LOG Error saving realm object ", error.localizedDescription)
        }
    }
}
