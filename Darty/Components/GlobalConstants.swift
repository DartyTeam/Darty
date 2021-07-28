//
//  GlobalConstants.swift
//  Darty
//
//  Created by Руслан Садыков on 12.07.2021.
//

import UIKit
import AudioToolbox

enum GlobalConstants {
    static let tabBarHeight: CGFloat = 65
    
    static let maximumGuests = 100
    static let maximumPrice = 9999
    
    static let interestsArray = [InterestModel(id: 0, title: "Игры", emoji: "🎮"),
                                     InterestModel(id: 1, title: "Бег", emoji: "🏈"),
                                     InterestModel(id: 2, title: "Музыка", emoji: "🧩"),
                                     InterestModel(id: 3, title: "Пение", emoji: "♦️"),
                                     InterestModel(id: 4, title: "Пианино", emoji: "⛳️"),
                                     InterestModel(id: 5, title: "Скейтбординг", emoji: "⛳️"),
                                     InterestModel(id: 6, title: "Спорт", emoji: "⛳️"),
                                     InterestModel(id: 7, title: "Программирование", emoji: "⛳️"),
                                     InterestModel(id: 8, title: "Путешествия", emoji: "⛳️"),
                                     InterestModel(id: 9, title: "Танцы", emoji: "⛳️")]
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
