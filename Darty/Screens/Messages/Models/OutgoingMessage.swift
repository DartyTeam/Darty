//
//  OutgoingMessage.swift
//  Darty
//
//  Created by Руслан Садыков on 06.08.2021.
//

import Foundation
import UIKit
import AVFoundation
//import FirebaseFirestoreSwift

class OutgoingMessage {
    
    class func send(chatId: String, text: String?, photo: UIImage?, video: URL?, audio: String?, audioDuration: Float = 0.0, location: Location?, memberIds: [String], completion: @escaping (Result<Void, Error>) -> Void) {
        
        let currentUser = AuthService.shared.currentUser!
        
        let message = LocalMessage()
        message.id = UUID().uuidString
        message.chatRoomId = chatId
        message.senderId = currentUser.id
        message.senderName = currentUser.username
        message.senderInitials = String(currentUser.username.first!)
        message.date = Date()
        message.status = GlobalConstants.kSENT
        
        if let text = text {
            sendTextMessage(message: message, text: text, memberIds: memberIds) { result in
                switch result {
                
                case .success():
                    print("Message \"\(message)\" saved local and send to firebase")
                    completion(.success(Void()))
                case .failure(let error):
                    print("ERROR_LOG Error save local and send to firebase message \"\(message)\" :", error.localizedDescription)
                    completion(.failure(error))
                }
            }
        }
        
        if let photo = photo {
            sendPictureMessage(message: message, photo: photo, memberIds: memberIds) { result in
                switch result {
                
                case .success():
                    print("Photo message \"\(message)\" saved local and send to firebase")
                    completion(.success(Void()))
                case .failure(let error):
                    print("ERROR_LOG Error save local and send to firebase photo message \"\(message)\" :", error.localizedDescription)
                    completion(.failure(error))
                }
            }
        }
        
        if let video = video {
            sendVideoMessage(message: message, video: video, memberIds: memberIds) { result in
                switch result {
                
                case .success():
                    print("Video message \"\(message)\" saved local and send to firebase")
                    completion(.success(Void()))
                case .failure(let error):
                    print("ERROR_LOG Error save local and send to firebase video message \"\(message)\" :", error.localizedDescription)
                    completion(.failure(error))
                }
            }
        }
        
        if let location = location {
            sendLocationMessage(message: message, location: location, memberIds: memberIds) { result in
                switch result {
                
                case .success():
                    print("Location message \"\(message)\" saved local and send to firebase")
                    completion(.success(Void()))
                case .failure(let error):
                    print("ERROR_LOG Error save local and send to firebase location message \"\(message)\" :", error.localizedDescription)
                    completion(.failure(error))
                }
            }
        }
        
        if let audio = audio {
            sendAudioMessage(message: message, audioFilename: audio, audioDuration: audioDuration, memberIds: memberIds) { result in
                switch result {
                case .success():
                    print("Audio message \"\(message)\" saved local and send to firebase")
                    completion(.success(Void()))
                case .failure(let error):
                    print("ERROR_LOG Error save local and send to firebase audio message \"\(message)\" :", error.localizedDescription)
                    completion(.failure(error))
                }
            }
        }
        
        // TODO: Send push notification
        
        FirestoreService.shared.updateRecents(chatRoomId: chatId, lastMessage: message.message, completion: nil)
    }
    
    class func sendMessage(message: LocalMessage, memberIds: [String], completion: @escaping (Result<Void, Error>) -> Void) {
        RealmManager.shared.saveToRealm(message)
        
        for memberId in memberIds {
            FirestoreService.shared.addMessage(message, memberId: memberId, completion: completion)
        }
    }
}

func sendTextMessage(message: LocalMessage, text: String, memberIds: [String], completion: @escaping (Result<Void, Error>) -> Void) {
    message.message = text
    message.type = GlobalConstants.kTEXT
    
    OutgoingMessage.sendMessage(message: message, memberIds: memberIds, completion: completion)
}

func sendPictureMessage(message: LocalMessage, photo: UIImage, memberIds: [String], completion: @escaping (Result<Void, Error>) -> Void) {
 
    message.message = "Picture Message"
    message.type = GlobalConstants.kPHOTO
    
    StorageService.shared.uploadPhotoMessage(photo: photo, to: message.chatRoomId) { result in
        switch result {
        
        case .success(let url):
            print("Successfull upload photo message: ", url)
            message.pictureUrl = url.absoluteString
            OutgoingMessage.sendMessage(message: message, memberIds: memberIds, completion: completion)
        case .failure(let error):
            print("ERROR_LOG Error upload photo message: ", error.localizedDescription)
            completion(.failure(error))
        }
    }
}

func sendVideoMessage(message: LocalMessage, video: URL, memberIds: [String], completion: @escaping (Result<Void, Error>) -> Void) {
    message.message = "Video Message"
    message.type = GlobalConstants.kVIDEO
    
    let asset = AVURLAsset(url: video, options: nil)
    let exportSession = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetHighestQuality)!
    exportSession.outputFileType = .mov
    exportSession.outputURL = video
    let data = NSData(contentsOf: exportSession.outputURL! as URL)
    
    let thumbnail = videoThumbnail(video: video)
    
    if let videoData = data as Data? {
        StorageService.shared.uploadVideoMessage(video: videoData, thumbnail: thumbnail, to: message.chatRoomId) { result in
            switch result {
            
            case .success(let uploadVideoResponse):
                print("Successfull upload video message: ", uploadVideoResponse)
                message.pictureUrl = uploadVideoResponse.thumbnailURL.absoluteString
                message.videoUrl = uploadVideoResponse.vodeoURL.absoluteString
                OutgoingMessage.sendMessage(message: message, memberIds: memberIds, completion: completion)
            case .failure(let error):
                print("ERROR_LOG Error upload video message: ", error.localizedDescription)
                completion(.failure(error))
            }
        }
    }
}

func videoThumbnail(video: URL) -> UIImage {
    let asset = AVURLAsset(url: video, options: nil)
    let imageGenerator = AVAssetImageGenerator(asset: asset)
    imageGenerator.appliesPreferredTrackTransform = true
    let time = CMTimeMakeWithSeconds(0.5, preferredTimescale: 1000)
//    var actualTime: CMTime = .zero
    var image: CGImage?
    
    do {
        image = try imageGenerator.copyCGImage(at: time, actualTime: .none)
    } catch let error as NSError {
        print("ERROR_LOG Error making thumbnail for video \(video): ", error.localizedDescription)
    }
    
    if let image = image {
        return UIImage(cgImage: image)
    } else {
        return (UIImage(systemName: "photo")?.withTintColor(.systemTeal, renderingMode: .alwaysOriginal).withAlignmentRectInsets(UIEdgeInsets(top: -32, left: -32, bottom: -32, right: -32)))!
    }
}

func sendLocationMessage(message: LocalMessage, location: Location, memberIds: [String], completion: @escaping (Result<Void, Error>) -> Void) {

    message.message = "Location message"
    message.type = GlobalConstants.kLOCATION
    message.latitude = location.location.coordinate.latitude
    message.longitude = location.location.coordinate.longitude
    
    OutgoingMessage.sendMessage(message: message, memberIds: memberIds, completion: completion)
}

func sendAudioMessage(message: LocalMessage, audioFilename: String, audioDuration: Float, memberIds: [String], completion: @escaping (Result<Void, Error>) -> Void) {

    message.message = "Audio message"
    message.type = GlobalConstants.kAUDIO
    
    StorageService.shared.uploadAudioMessage(audioFilename: audioFilename, to: message.chatRoomId) { result in
        switch result {
        
        case .success(let audioUrl):
            print("Successfull upload audio message: ", audioUrl)
            message.audioUrl = audioUrl.absoluteString
            message.audioDuration = Double(audioDuration)
            OutgoingMessage.sendMessage(message: message, memberIds: memberIds, completion: completion)
        case .failure(let error):
            print("ERROR_LOG Error upload audio message: ", error.localizedDescription)
            completion(.failure(error))
        }
    }
}
