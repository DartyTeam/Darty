//
//  MessageCellDelegate.swift
//  Darty
//
//  Created by Руслан Садыков on 06.08.2021.
//

import Foundation
import MessageKit
import AVFoundation
import AVKit
import Agrume

extension NewChatVC: MessageCellDelegate {
    func didTapImage(in cell: MessageCollectionViewCell) {
        if let indexPath = messagesCollectionView.indexPath(for: cell) {
            let mkMessage = mkMessages[indexPath.section]
            
            if let photoItem = mkMessage.photoItem, let photoItemImage = photoItem.image {
                cell.showAnimation { [weak self] in
                    let agrume = Agrume(images: [photoItemImage])
                    self?.present(agrume, animated: true, completion: nil)
                }
            } else if let videoItem = mkMessage.videoItem, let videoItemUrl = videoItem.url {
                let player = AVPlayer(url: videoItemUrl)
                let moviePlayer = AVPlayerViewController()
                let session = AVAudioSession.sharedInstance()
                try! session.setCategory(.playAndRecord, mode: .default, options: .defaultToSpeaker)
                moviePlayer.player = player
                
                present(moviePlayer, animated: true) {
                    moviePlayer.player?.play()
                }
            }
        }
    }
    
    func didTapMessage(in cell: MessageCollectionViewCell) {
        if let indexPath = messagesCollectionView.indexPath(for: cell) {
            let mkMessage = mkMessages[indexPath.section]
            
            if mkMessage.locationItem != nil, let location = mkMessage.locationItem?.location {
                let mapVC = MapVC(location: location)
                navigationController?.pushViewController(mapVC, animated: true)
            }
        }
    }

    func didTapPlayButton(in cell: AudioMessageCell) {
        guard let indexPath = messagesCollectionView.indexPath(for: cell),
              let message = messagesCollectionView.messagesDataSource?.messageForItem(at: indexPath, in: messagesCollectionView) else {
            print("Failed to identify message when audio cell receive tap gesture")
            return
        }
        guard let cell = cell as? DAudioMessageCell else {
            print("Error get DAudioMessageCell")
            return
        }
        guard audioController.state != .stopped else {
            // There is no audio sound playing - prepare to start playing for given audio message
            audioController.playSound(for: message, in: cell)
            print("asdioajsidjadsioajsdmiasdmasoidasd")
            return
        }
        if audioController.playingMessage?.messageId == message.messageId {
            // tap occur in the current cell that is playing audio sound
            if audioController.state == .playing {

                audioController.pauseSound(for: message, in: cell)
            } else {
                audioController.resumeSound()
            }
        } else {
            // tap occur in a difference cell that the one is currently playing sound. First stop currently playing and start the sound for given message
            audioController.stopAnyOngoingPlaying()
            audioController.playSound(for: message, in: cell)
        }
    }
}
