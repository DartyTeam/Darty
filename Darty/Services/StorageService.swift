//
//  StorageService.swift
//  Darty
//
//  Created by Руслан Садыков on 28.06.2021.
//

import FirebaseAuth
import FirebaseStorage

struct UploadVideoResponse {
    let vodeoURL: URL
    let thumbnailURL: URL
}

class StorageService {
    
    static let shared = StorageService()
    
    private init () {}
    
    let storageRef = Storage.storage().reference()
    
    private var avatarsRef: StorageReference {
        return storageRef.child("avatars")
    }
    
    private var chatsRef: StorageReference {
        return storageRef.child("chats")
    }
    
    private var mediaMessagesPhotoRef: StorageReference {
        return storageRef.child("mediaMessages/photo/")
    }
    
    private var mediaMessagesVideoRef: StorageReference {
        return storageRef.child("mediaMessages/video/")
    }
    
    private var mediaMessagesAudioRef: StorageReference {
        return storageRef.child("mediaMessages/audio/")
    }
    
    private var currentUserId: String {
        guard let currentUser = Auth.auth().currentUser else { return "error" }
        return currentUser.uid
    }
    
    func upload(photo: UIImage, completion: @escaping (Result<URL, Error>) -> Void) {
        guard let scaledImage = photo.scaledToSafeUploadSize, let imageData = scaledImage.jpegData(compressionQuality: 0.4) else { return }
        
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        
        let filename = "\([currentUserId, String(Date().timeIntervalSince1970)].joined()).jpg"
    
        avatarsRef.child("_\(filename)").putData(imageData, metadata: metadata) { (metadata, error) in
            guard let _ = metadata else {
                completion(.failure(error!))
                return
            }
            
            self.avatarsRef.child("_\(filename)").downloadURL { (url, error) in
                guard let downloadURL = url else {
                    completion(.failure(error!))
                    return
                }
                completion(.success(downloadURL))
                
                // MARK: - Save image locally
                StorageService.saveFileLocally(fileData: photo.jpegData(compressionQuality: 1.0)! as NSData, fileName: filename)
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
        
        let imageName = "\([UUID().uuidString, partyId].joined()).jpg"
        
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
        
    func uploadPhotoMessage(photo: UIImage, to chatRoomId: String, completion: @escaping (Result<URL, Error>) -> Void) {
        guard let scaledImage = photo.scaledToSafeUploadSize, let imageData = scaledImage.jpegData(compressionQuality: 0.4) else { return }
        
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        
        let fileName = "\(DateFormatter.ddMMyyyyHHmmss.string(from: Date())).jpg"
       
        self.mediaMessagesPhotoRef.child(chatRoomId).child("_\(fileName)").putData(imageData, metadata: metadata) { (metadata, error) in
            guard let _ = metadata else {
                completion(.failure(error!))
                return
            }
            
            self.mediaMessagesPhotoRef.child(chatRoomId).child("_\(fileName)").downloadURL { (url, error) in
                guard let downloadURL = url else {
                    completion(.failure(error!))
                    return
                }
                completion(.success(downloadURL))
            }
            
            // MARK: - Save image locally
            StorageService.saveFileLocally(fileData: photo.jpegData(compressionQuality: 1)! as NSData, fileName: "\(fileName)")
        }
    }
    
    func uploadVideoMessage(video: Data, thumbnail: UIImage, to chatRoomId: String, completion: @escaping (Result<UploadVideoResponse, Error>) -> Void) {
        
        guard let scaledImage = thumbnail.scaledToSafeUploadSize, let thumbnailData = scaledImage.jpegData(compressionQuality: 0.4) else { return }

        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        
        let videoFileName = "\(DateFormatter.ddMMyyyyHHmmss.string(from: Date())).mov"
        let photoFileName = "\(DateFormatter.ddMMyyyyHHmmss.string(from: Date())).jpg"
        
        var task: StorageUploadTask!
        
        task = self.mediaMessagesPhotoRef.child(chatRoomId).child("_\(photoFileName)").putData(thumbnailData, metadata: metadata) { (metadata, error) in
            task.removeAllObservers()
            #warning("Тут должно быть вызов скрытия анимации прогресса")
            guard let _ = metadata else {
                completion(.failure(error!))
                return
            }

            self.mediaMessagesPhotoRef.child(chatRoomId).child("_\(photoFileName)").downloadURL { (url, error) in
                guard let thumbnailUrl = url else {
                    completion(.failure(error!))
                    return
                }
                
                self.mediaMessagesVideoRef.child(chatRoomId).child("_\(videoFileName)").putData(video, metadata: nil) { (metadata, error) in
                    guard let _ = metadata else {
                        completion(.failure(error!))
                        return
                    }
                    
                    self.mediaMessagesVideoRef.child(chatRoomId).child("_\(videoFileName)").downloadURL { (url, error) in
                        guard let videoUrl = url else {
                            completion(.failure(error!))
                            return
                        }
                        completion(.success(UploadVideoResponse(vodeoURL: videoUrl, thumbnailURL: thumbnailUrl)))
                    }
                    
                    // MARK: - Save video locally
                    StorageService.saveFileLocally(fileData: video as NSData, fileName: "\(videoFileName)")
                }
            }

            // MARK: - Save image locally
            StorageService.saveFileLocally(fileData: thumbnail.jpegData(compressionQuality: 1)! as NSData, fileName: "\(photoFileName)")
        }
        
        task.observe(StorageTaskStatus.progress) { snapshot in
            let progress = snapshot.progress!.completedUnitCount / snapshot.progress!.totalUnitCount
            #warning("Нужно передавать прогресс какому-нибудь лоадеру")
        }
    }
    
    // MARK: - Upload audio message
    func uploadAudioMessage(audioFilename: String, to chatRoomId: String, completion: @escaping (Result<URL, Error>) -> Void) {
        let metadata = StorageMetadata()
//        metadata.contentType = "image/jpeg"
        
        print("asdijaisdjaisdjaisodjasidj: ", audioFilename)
        let fileName = "\(audioFilename).m4a"
        
        var task: StorageUploadTask!
        
        if fileExistsAtPath(path: fileName) {
            if let audioData = NSData(contentsOfFile: fileInDocumentsDirectory(fileName: fileName)) {
                task = self.mediaMessagesAudioRef.child(chatRoomId).child("_\(fileName)").putData(audioData as Data, metadata: nil) { (metadata, error) in
                    task.removeAllObservers()
                    print("asoidjajosidjoiasjidoajsjdia")
                    #warning("Тут должно быть вызов скрытия анимации прогресса")
                    guard let _ = metadata else {
                        completion(.failure(error!))
                        return
                    }
                    
                    self.mediaMessagesAudioRef.child(chatRoomId).child("_\(fileName)").downloadURL { (url, error) in
                        guard let videoUrl = url else {
                            completion(.failure(error!))
                            return
                        }
                        completion(.success(videoUrl))
                    }
                }
                
                task.observe(StorageTaskStatus.progress) { snapshot in
                    let progress = snapshot.progress!.completedUnitCount / snapshot.progress!.totalUnitCount
                    #warning("Нужно передавать прогресс какому-нибудь лоадеру")
                }
            } else {
                print("ERROR_LOG Error get audio data from documents directory \(fileName)")
            }
        } else {
            print("ERROR_LOG File does not exist in path \(fileName)")
        }
    }
    
    func downloadVideo(url: URL, completion: @escaping (Result<String, Error>) -> Void) {
        
        let videoFileName = fileNameFrom(fileUrl: url.absoluteString) + ".mov"
        
        if fileExistsAtPath(path: videoFileName) {
            completion(.success(videoFileName))
        } else {
            let downloadQueue = DispatchQueue(label: "VideoDownloadQueue")
            downloadQueue.async {
                let ref = Storage.storage().reference(forURL: url.absoluteString)
                let megaByte = Int64(1 * 1024 * 1024 * 1024)
                ref.getData(maxSize: megaByte) { (data, error) in
                    guard let videoData = data else {
                        completion(.failure(error!))
                        return
                    }
                    
                    // MARK: - Save video locally
                    StorageService.saveFileLocally(fileData: videoData as NSData, fileName: "\(videoFileName)")
                    
                    DispatchQueue.main.async {
                        completion(.success(videoFileName))
                    }
                }
            }
        }
        
        print(fileNameFrom(fileUrl: url.absoluteString))
    }
    
    func downloadAudio(audioUrl: String, completion: @escaping (Result<String, Error>) -> Void) {
        
        let audioFilename = fileNameFrom(fileUrl: audioUrl) + ".m4a"
        
        if fileExistsAtPath(path: audioFilename) {
            completion(.success(audioFilename))
        } else {
            let downloadQueue = DispatchQueue(label: "AudioDownloadQueue")
            downloadQueue.async {
                let ref = Storage.storage().reference(forURL: audioUrl)
                let megaByte = Int64(1 * 1024 * 1024 * 1024)
                ref.getData(maxSize: megaByte) { (data, error) in
                    guard let videoData = data else {
                        completion(.failure(error!))
                        return
                    }
                    
                    // MARK: - Save video locally
                    StorageService.saveFileLocally(fileData: videoData as NSData, fileName: "\(audioFilename)")
                    
                    DispatchQueue.main.async {
                        completion(.success(audioFilename))
                    }
                }
            }
        }
    }
    
    func downloadImage(url: URL, completion: @escaping (Result<UIImage?, Error>) -> Void) {
        let imageFileName = fileNameFrom(fileUrl: url.absoluteString)
        if fileExistsAtPath(path: imageFileName) {
            if let contentsOfFile = UIImage(contentsOfFile: fileInDocumentsDirectory(fileName: imageFileName)) {
                completion(.success(contentsOfFile))
            } else {
                print("ERROR_LOG Coundnt convert local image")
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

