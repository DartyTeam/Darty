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
    
    static let interestsArray = [InterestModel(id: 0, title: "Видеоигры", emoji: "🎮"),
                                     InterestModel(id: 1, title: "Бег", emoji: "🏃"),
                                     InterestModel(id: 2, title: "Музыка", emoji: "🎶"),
                                     InterestModel(id: 3, title: "Пение", emoji: "🎤"),
                                     InterestModel(id: 4, title: "Пианино", emoji: "🎹"),
                                     InterestModel(id: 5, title: "Скейтбординг", emoji: "🛹"),
                                     InterestModel(id: 6, title: "Спорт", emoji: "💪"),
                                     InterestModel(id: 7, title: "Программирование", emoji: "🧑‍💻"),
                                     InterestModel(id: 8, title: "Путешествия", emoji: "🗺"),
                                     InterestModel(id: 9, title: "Блогинг", emoji: "🪄"),
                                     InterestModel(id: 10, title: "Велосипед", emoji: "🚲"),
                                     InterestModel(id: 11, title: "Бадментон", emoji: "🏸"),
                                     InterestModel(id: 12, title: "Настольный теннис", emoji: "🏓"),
                                     InterestModel(id: 13, title: "Большой теннис", emoji: "🎾"),
                                     InterestModel(id: 14, title: "Волейбол", emoji: "🏐"),
                                     InterestModel(id: 15, title: "Баскетбол", emoji: "🏀"),
                                     InterestModel(id: 16, title: "Футбол", emoji: "⚽️"),
                                     InterestModel(id: 17, title: "Хоккей", emoji: "🏒"),
                                     InterestModel(id: 18, title: "Боевые искусства", emoji: "🥋"),
                                     InterestModel(id: 19, title: "Фигурное катания", emoji: "⛸"),
                                     InterestModel(id: 20, title: "Роликовые коньки", emoji: "🛼"),
                                     InterestModel(id: 21, title: "Гольф", emoji: "🏌️"),
                                     InterestModel(id: 22, title: "Тяжелая атлетика", emoji: "🏋️"),
                                     InterestModel(id: 23, title: "Борьба", emoji: "🤼"),
                                     InterestModel(id: 24, title: "Гандбол", emoji: "🤾"),
                                     InterestModel(id: 25, title: "Йога", emoji: "🧘"),
                                     InterestModel(id: 26, title: "Сёрфинг", emoji: "🏄"),
                                     InterestModel(id: 27, title: "Плавание", emoji: "🏊"),
                                     InterestModel(id: 28, title: "Скалалазание", emoji: "🧗"),
                                     InterestModel(id: 29, title: "Кино", emoji: "🎬"),
                                     InterestModel(id: 30, title: "Барабаны", emoji: "🥁"),
                                     InterestModel(id: 31, title: "Саксафон", emoji: "🎷"),
                                     InterestModel(id: 32, title: "Гитара", emoji: "🎸"),
                                     InterestModel(id: 33, title: "Скрипка", emoji: "🎻"),
                                     InterestModel(id: 34, title: "Боулинг", emoji: "🎳"),
                                     InterestModel(id: 35, title: "Мотоциклы", emoji: "🏍"),
                                     InterestModel(id: 36, title: "Рыбалка", emoji: "🎣"),
                                     InterestModel(id: 37, title: "Астрономия", emoji: "🔭"),
                                     InterestModel(id: 38, title: "Физика", emoji: "⚛️"),
                                     InterestModel(id: 39, title: "Химия", emoji: "🧪"),
                                     InterestModel(id: 40, title: "Математика", emoji: "🧮"),
                                     InterestModel(id: 41, title: "Литература", emoji: "🪶"),
                                     InterestModel(id: 42, title: "История", emoji: "📜"),
                                     InterestModel(id: 43, title: "Кросовки", emoji: "👟"),
                                     InterestModel(id: 44, title: "Автомобили", emoji: "🚗"),
                                     InterestModel(id: 45, title: "Гонки", emoji: "🏎"),
                                     InterestModel(id: 46, title: "Самокаты", emoji: "🛴"),
                                     InterestModel(id: 47, title: "Фотография", emoji: "📷"),
                                     InterestModel(id: 48, title: "Видеография", emoji: "🎥"),
                                     InterestModel(id: 49, title: "Подкасты", emoji: "🎙"),
                                     InterestModel(id: 50, title: "Медицина", emoji: "🧑‍⚕️"),
                                     InterestModel(id: 51, title: "Дизайн", emoji: "🧑‍🎨"),
                                     InterestModel(id: 52, title: "Шитье", emoji: "🪡"),
                                     InterestModel(id: 52, title: "Готовка", emoji: "🧑‍🍳"),
                                     InterestModel(id: 53, title: "Труба", emoji: "🎺"),
                                     InterestModel(id: 54, title: "Аккордеон", emoji: "🪗"),
                                     InterestModel(id: 55, title: "Авиация", emoji: "🛩"),
                                     InterestModel(id: 56, title: "Мореплавание", emoji: "⛵️"),
                                     InterestModel(id: 57, title: "Строительство", emoji: "🏗"),
                                     InterestModel(id: 58, title: "Походы", emoji: "🏕"),
                                     InterestModel(id: 59, title: "DIY", emoji: "🛠"),
                                     InterestModel(id: 60, title: "Рисование", emoji: "🖼"),
                                     InterestModel(id: 61, title: "Цветы", emoji: "💐"),
    ]
    
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
