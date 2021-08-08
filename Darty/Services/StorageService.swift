//
//  StorageService.swift
//  Darty
//
//  Created by Руслан Садыков on 28.06.2021.
//

import FirebaseAuth
import FirebaseStorage

class StorageService {
    
    static let shared = StorageService()
    
    let storageRef = Storage.storage().reference()
    
    private var avatarsRef: StorageReference {
        return storageRef.child("avatars")
    }
    
    private var chatsRef: StorageReference {
        return storageRef.child("chats")
    }
    
    private var currentUserId: String {
        guard let currentUser = Auth.auth().currentUser else { return "error" }
        return currentUser.uid
    }
    
    func upload(photo: UIImage, completion: @escaping (Result<URL, Error>) -> Void) {
        guard let scaledImage = photo.scaledToSafeUploadSize, let imageData = scaledImage.jpegData(compressionQuality: 0.4) else { return }
        
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
    
        avatarsRef.child("_\(currentUserId)").putData(imageData, metadata: metadata) { (metadata, error) in
            guard let _ = metadata else {
                completion(.failure(error!))
                return
            }
            
            self.avatarsRef.child(self.currentUserId).downloadURL { (url, error) in
                guard let downloadURL = url else {
                    completion(.failure(error!))
                    return
                }
                completion(.success(downloadURL))
                
                // MARK: - Save image locally
                StorageService.saveFileLocally(fileData: photo.jpegData(compressionQuality: 1.0)! as NSData, fileName: "\(self.currentUserId)")
            }
        }
    }
    
    func delete(stringUrl: String) {
        
    }
    
    private var partiesImagesRef: StorageReference {
        return storageRef.child("partiesImages")
    }
    
    func uploadPartyImage(photo: UIImage, partyId: String, completion: @escaping (Result<URL, Error>) -> Void) {
        guard let scaledImage = photo.scaledToSafeUploadSize, let imageData = scaledImage.jpegData(compressionQuality: 0.4) else { return }
        
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        
        let imageName = [UUID().uuidString, partyId].joined()
        
        partiesImagesRef.child(currentUserId).child("_\(imageName)").putData(imageData, metadata: metadata) { (metadata, error) in
            guard let _ = metadata else {
                completion(.failure(error!))
                return
            }
            
            self.partiesImagesRef.child(self.currentUserId).child("_\(imageName)").downloadURL { (url, error) in
                guard let downloadURL = url else {
                    completion(.failure(error!))
                    return
                }
                completion(.success(downloadURL))
                
                // MARK: - Save image locally
                StorageService.saveFileLocally(fileData: photo.jpegData(compressionQuality: 1.0)! as NSData, fileName: "\(imageName)")
            }
        }
    }
    
    func uploadImageMessage(photo: UIImage, to chat: ChatModel, completion: @escaping (Result<URL, Error>) -> Void) {
        guard let scaledImage = photo.scaledToSafeUploadSize, let imageData = scaledImage.jpegData(compressionQuality: 0.4) else { return }
        
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        
        let imageName = [UUID().uuidString, String(Date().timeIntervalSince1970)].joined()

        let chatName = [chat.friendId, currentUserId].joined(separator: ".")
        self.chatsRef.child(chatName).child(imageName).putData(imageData, metadata: metadata) { (metadata, error) in
            guard let _ = metadata else {
                completion(.failure(error!))
                return
            }
            
            self.chatsRef.child(chatName).child(imageName).downloadURL { (url, error) in
                guard let downloadURL = url else {
                    completion(.failure(error!))
                    return
                }
                completion(.success(downloadURL))
            }
        }
    }
    
    func downloadImage(url: URL, completion: @escaping (Result<UIImage?, Error>) -> Void) {
        let imageFileName = fileNameFrom(fileUrl: url.absoluteString)
        if fileExistsAtPath(path: imageFileName) {
            print("asdiojasd: ")
            if let contentsOfFile = UIImage(contentsOfFile: fileInDocumentsDirectory(fileName: imageFileName)) {
                completion(.success(contentsOfFile))
            } else {
                print("coundnt convert local image")
                completion(.failure(StorageErrors.couldntConvertLocalImage))
            }
            
        } else {
            let ref = Storage.storage().reference(forURL: url.absoluteString)
            let megaByte = Int64(1 * 1024 * 1024)
            ref.getData(maxSize: megaByte) { (data, error) in
                guard let imageData = data else {
                    completion(.failure(error!))
                    return
                }
                completion(.success(UIImage(data: imageData)))
                
                // MARK: - Save image locally
                StorageService.saveFileLocally(fileData: imageData as NSData, fileName: "\(imageFileName)")
            }
        }
        
        print("ADUjaoisdj: ", url.absoluteString)
        print(fileNameFrom(fileUrl: url.absoluteString))
    }
    
    func fileNameFrom(fileUrl: String) -> String {
        let name = (fileUrl.components(separatedBy: "_").last)?.components(separatedBy: "?").first
        return name ?? "ERRORGETNAME"
    }
    
    // MARK: - Save locally
    class func saveFileLocally(fileData: NSData, fileName: String) {
        let docUrl = getDocumentsUrl().appendingPathComponent(fileName, isDirectory: false)
        fileData.write(to: docUrl, atomically: true)
    }
}

// Helpers
func fileInDocumentsDirectory(fileName: String) -> String {
    return getDocumentsUrl().appendingPathComponent(fileName).path
}

func getDocumentsUrl() -> URL {
    return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last!
}

func fileExistsAtPath(path: String) -> Bool {
    return FileManager.default.fileExists(atPath: fileInDocumentsDirectory(fileName: path))
}

func timeElapsed(_ date: Date) -> String {
    let seconds = Date().timeIntervalSince(date)
    
    var elapsed = ""
    
    if seconds < 60 {
        elapsed = "Только что"
    } else if seconds < 60 * 60 {
        let minutes = Int(seconds / 60)
        let minText = minutes > 1 ? "минут" : "минута"
        elapsed = " \(minutes) \(minText)"
    } else if seconds < 24 * 60 * 60 {
        let hours = Int(seconds / (60 * 60))
        let hourText = hours > 1 ? "часов" : "час"
        elapsed = " \(hours) \(hourText)"
    } else {
        elapsed = DateFormatter.ddMMyy.string(from: date)
    }
    
    return elapsed
}

