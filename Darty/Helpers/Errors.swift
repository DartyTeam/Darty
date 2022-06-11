//
//  Errors.swift
//  Darty
//
//  Created by Руслан Садыков on 28.06.2021.
//

import Foundation

enum Errors {
    case notFilled
    case invalidEmail
    case unknownError
    case serverError
}

extension Errors: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .notFilled:
            return NSLocalizedString("Заполните все поля", comment: "")
        case .invalidEmail:
            return NSLocalizedString("Формат почты не является допустимым", comment: "")
        case .unknownError:
            return NSLocalizedString("Неизвестная ошибка", comment: "")
        case .serverError:
            return NSLocalizedString("Ошибка сервера", comment: "")
        }
    }
}

enum UserError {
    case notFilled
    case photoNotExist
    case cannotUnwrapToUserModel
    case cannotGetUserInfo
}

extension UserError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .notFilled:
            return NSLocalizedString("Заполните все поля", comment: "")
        case .photoNotExist:
            return NSLocalizedString("Пользователь не выбрал фото", comment: "")
        case .cannotGetUserInfo:
            return NSLocalizedString("Невозможно загрузить информацию о User из Firebase", comment: "")
        case .cannotUnwrapToUserModel:
            return NSLocalizedString("Невозможно конвертировать UserModel из User", comment: "")
        }
    }
}

enum PartyError {
    case cannotUnwrapToParty
    case cannotGetPartyInfo
    case noWaitingGuests
    case noApprovedGuests
}

extension PartyError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .cannotUnwrapToParty:
            return NSLocalizedString("Невозможно конвертировать PartyModel из Firebase", comment: "")
        case .cannotGetPartyInfo:
            return NSLocalizedString("Невозможно загрузить информацию о Party из Firebase", comment: "")
        case .noWaitingGuests:
            return NSLocalizedString("Отсутствуют гости, ожидающие одобрения", comment: "")
        case .noApprovedGuests:
            return NSLocalizedString("Отсутствуют подтвержденные гости", comment: "")
        }
    }
}

enum StorageErrors {
    case couldntConvertLocalImage
    case couldntConvertLocalJson
}

extension StorageErrors: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .couldntConvertLocalImage:
            return NSLocalizedString("Невозможно конвертировать локальное изображение", comment: "")
        case .couldntConvertLocalJson:
            return NSLocalizedString("Не удалось конвертировать локальный json файл в модель данных InterestModel", comment: "")
        }
    }
}


enum ChatErrors {
    case noDocForRecent
    case errorMakeRecentChatModel
}

extension ChatErrors: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .noDocForRecent:
            return NSLocalizedString("Не документов для чата в базе данных", comment: "")
        case .errorMakeRecentChatModel:
            return NSLocalizedString("Ошибка получения модели чата из документа в Firebase", comment: "")
        }
    }
}

enum AuthError: LocalizedError {
    case noSavedCredential
    case noSavedVerificationID
    case noUserData
    case userCanceledAuth

    var errorDescription: String? {
        switch self {
        case .noSavedCredential:
            return NSLocalizedString("Отсуствует сохраненные данные авторизации пользователя", comment: "")
        case .noSavedVerificationID:
            return NSLocalizedString("Попробуйте запросить код из СМС снова", comment: "")
        case .noUserData:
            return NSLocalizedString("Не удалось получить данные пользователя", comment: "")
        case .userCanceledAuth:
            return NSLocalizedString("Вход был отменен", comment: "")
        }
    }
}
