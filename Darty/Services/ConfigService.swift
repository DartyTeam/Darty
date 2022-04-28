//
//  ConfigService.swift
//  Darty
//
//  Created by Руслан Садыков on 19.04.2022.
//

import FirebaseStorage
import SPAlert
import UIKit

final class ConfigService {

    static let shared = ConfigService()

    var interestsArray: [InterestModel] = []

    private init() {}

    private let storageRef = Storage.storage().reference()
    private var configsRef: StorageReference {
        return storageRef.child("Configs")
    }

    func getInterests(completion: ((Result<Void, Error>)->())? = nil) {
        let fileName = "interests.json"
        let megaByte = Int64(1 * 1024 * 1024 * 1024)
        configsRef.child(fileName).getData(maxSize: megaByte) { data, error in
            guard let data = data else {
                print("ERROR_LOG Error get interests from firebase database because data is nil")
                self.getFromCache(for: fileName, completion: completion)
                return
            }
            do {
                let interestsArray = try JSONDecoder().decode(InterestsModel.self, from: data)
                print("Successfully get interests array: ", interestsArray)
                StorageService.saveFileLocally(fileData: data as NSData, fileName: fileName)
                self.interestsArray = interestsArray.interests
                completion?(.success(Void()))
            } catch let error {
                completion?(.failure(error))
                print("ERROR_LOG Error decode json to InterestModel: ", error.localizedDescription)
            }
        }
    }

    private func getFromCache(for fileName: String, completion: ((Result<Void, Error>)->())? = nil) {
        if fileExistsAt(path: fileName) {
            if let data = fileInDocumentsDirectory(fileName: fileName).data(using: .utf8) {
                do {
                    let interestsArray = try JSONDecoder().decode(InterestsModel.self, from: data)
                    print("Successfully get interests array: ", interestsArray)
                    self.interestsArray = interestsArray.interests
                    completion?(.success(Void()))
                } catch let error {
                    print("ERROR_LOG Error decode json to InterestModel: ", error.localizedDescription)
                    completion?(.failure(StorageErrors.couldntConvertLocalJson))
                }
            } else {
                print("ERROR_LOG Coundnt convert local image")
                completion?(.failure(StorageErrors.couldntConvertLocalJson))
            }
        } else {
            completion?(.failure(Errors.serverError))
        }
    }
}
