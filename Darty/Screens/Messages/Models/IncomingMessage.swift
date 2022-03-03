//
//  IncomingMessage.swift
//  Darty
//
//  Created by Руслан Садыков on 06.08.2021.
//

import Foundation
import MessageKit
import CoreLocation

class IncomingMessage {
    
    var messageCollectionView: MessagesViewController
    
    init(_collectionView: MessagesViewController) {
        self.messageCollectionView = _collectionView
    }
    
    // MARK: - CreateMessage
    func createMessage(localMessage: LocalMessage) -> MKMessage? {
        let mkMessage = MKMessage(message: localMessage)
        
        if localMessage.type == GlobalConstants.kPHOTO {
            let photoItem = PhotoMessage(path: localMessage.pictureUrl)
            mkMessage.photoItem = photoItem
            mkMessage.kind = MessageKind.photo(photoItem)

            if let urlPhoto = URL(string: localMessage.pictureUrl) {
                StorageService.shared.downloadImage(url: urlPhoto) { result in
                    switch result {
                    
                    case .success(let image):
                        mkMessage.photoItem?.image = image
                        self.messageCollectionView.messagesCollectionView.reloadData()
                    case .failure(let error):
                        print("ERROR_LOG Error download image by url \(urlPhoto): ", error.localizedDescription)
                    }
                }
            } else {
                print("ERROR_LOG Error get url from picture in message: \(localMessage)")
            }
        } else if localMessage.type == GlobalConstants.kVIDEO {
            if let urlThumbnail = URL(string: localMessage.pictureUrl) {
                if let urlVideo = URL(string: localMessage.videoUrl) {
                    StorageService.shared.downloadImage(url: urlThumbnail) { result in
                        switch result {
                        
                        case .success(let thumbnailUrl):
                            StorageService.shared.downloadVideo(url: urlVideo) { result in
                                switch result {
                                
                                case .success(let videoFilename):
                                    let videoURL = URL(fileURLWithPath: fileInDocumentsDirectory(fileName: videoFilename))
                                    let videoItem = VideoMessage(url: videoURL)
                                    mkMessage.videoItem = videoItem
                                    mkMessage.kind = MessageKind.video(videoItem)
                                case .failure(let error):
                                    print("ERROR_LOG Error download video by url \(urlVideo): ", error.localizedDescription)
                                }
                                
                                mkMessage.videoItem?.image = thumbnailUrl
                                self.messageCollectionView.messagesCollectionView.reloadData()
                            }
                        case .failure(let error):
                            print("ERROR_LOG Error download thumbnail by url \(urlThumbnail): ", error.localizedDescription)
                        }
                    }
                } else {
                    print("ERROR_LOG Error get url from video in message: \(localMessage)")
                }
            } else {
                print("ERROR_LOG Error get url from picture in message: \(localMessage)")
            }
        } else if localMessage.type == GlobalConstants.kLOCATION {
            let locationItem = LocationMessage(location: CLLocation(latitude: localMessage.latitude, longitude: localMessage.longitude))
            mkMessage.kind = MessageKind.location(locationItem)
            mkMessage.locationItem = locationItem
        } else if localMessage.type == GlobalConstants.kAUDIO {
            let audioItem = AudioMessage(duration: Float(localMessage.audioDuration))
            mkMessage.kind = MessageKind.audio(audioItem)
            mkMessage.audioItem = audioItem
            
            StorageService.shared.downloadAudio(audioUrl: localMessage.audioUrl) { result in
                switch result {
                
                case .success(let audioFilename):
                    let audioUrl = URL(fileURLWithPath: fileInDocumentsDirectory(fileName: audioFilename))
                    mkMessage.audioItem?.url = audioUrl
                case .failure(let error):
                    print("ERROR_LOG Error download audio by url \(localMessage.audioUrl): ", error.localizedDescription)
                }
            }
            self.messageCollectionView.messagesCollectionView.reloadData()
        }
        
        return mkMessage
    }
}
