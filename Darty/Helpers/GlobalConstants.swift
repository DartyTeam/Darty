//
//  GlobalConstants.swift
//  Darty
//
//  Created by Руслан Садыков on 12.07.2021.
//

import UIKit
import AudioToolbox

enum GlobalConstants {
    static let tabBarHeight: CGFloat = 100
    
    static let maximumGuests = 100
    static let maximumPrice = 9999
    
    // MARK: - keys
    static let kCHATROOMID = "chatRoomId"
    static let kSENDERID = "senderId"
    
    static let kSENT = "sent"
    static let kREAD = "read"
    static let kSTATUS = "status"
    static let kREADDATE = "date"
    
    static let kTEXT = "text"
    static let kPHOTO = "photo"
    static let kVIDEO = "video"
    static let kAUDIO = "audio"
    static let kLOCATION = "location"
    
    static let kDATE = "date"
    
    static let changedUserDataNotification = Notification(name: Notification.Name("changedUserData"))
    static let changedUserInterestsNotification = Notification(name: Notification.Name("changedUserInterests"))

    static let userImageHeroId = "ironMan"
}

enum Vibration {
      case error
      case success
      case warning
      case light
      case medium
      case heavy
      @available(iOS 13.0, *)
      case soft
      @available(iOS 13.0, *)
      case rigid
      case selection
      case oldSchool

      public func vibrate() {
          switch self {
          case .error:
              UINotificationFeedbackGenerator().notificationOccurred(.error)
          case .success:
              UINotificationFeedbackGenerator().notificationOccurred(.success)
          case .warning:
              UINotificationFeedbackGenerator().notificationOccurred(.warning)
          case .light:
              UIImpactFeedbackGenerator(style: .light).impactOccurred()
          case .medium:
              UIImpactFeedbackGenerator(style: .medium).impactOccurred()
          case .heavy:
              UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
          case .soft:
              if #available(iOS 13.0, *) {
                  UIImpactFeedbackGenerator(style: .soft).impactOccurred()
              }
          case .rigid:
              if #available(iOS 13.0, *) {
                  UIImpactFeedbackGenerator(style: .rigid).impactOccurred()
              }
          case .selection:
              UISelectionFeedbackGenerator().selectionChanged()
          case .oldSchool:
              AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
          }
      }
  }
