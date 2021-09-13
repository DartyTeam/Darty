//
//  InstagramResponse.swift
//  Darty
//
//  Created by Руслан Садыков on 11.09.2021.
//

import Foundation

struct InstagramTestUser: Codable {
    var accessToken: String
    var userId: Int
    
    enum CodingKeys : String, CodingKey {
        case accessToken = "access_token"
        case userId = "user_id"
    }
}

struct InstagramUser: Codable {
    var id: String
    var username: String
}

struct InstaFeed: Codable {
    var error: InstaError?
    var data: [InstaMediaData]?
    var paging: InstaPagingData?
}

struct InstaMediaData: Codable {
    var id: String
    var caption: String?
    var mediaUrl: URL
    var mediaType: InstaMediaType
    var username: String
    var timestamp: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case caption
        case mediaType = "media_type"
        case mediaUrl = "media_url"
        case username
        case timestamp
    }
}

struct InstaPagingData: Codable {
    var cursors: InstaCursorData
    var next: String
}

struct InstaCursorData: Codable {
    var before: String
    var after: String
}

struct InstagramMedia: Codable {
    var id: String
    var mediaType: InstaMediaType
    var mediaUrl: String
    var username: String
    var timestamp: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case mediaType = "media_type"
        case mediaUrl = "media_url"
        case username
        case timestamp
    }
}

enum InstaMediaType: String, Codable {
    case IMAGE
    case VIDEO
    case CAROUSEL_ALBUM
}

struct InstaLongTermAccessToken: Codable {
    var error: InstaError?
    var accessToken: String?
    var tokenType: String?
    var expiresIn: Int?
    
    enum CodingKeys: String, CodingKey {
        case error
        case accessToken = "access_token"
        case tokenType = "token_type"
        case expiresIn = "expires_in"
    }
}

struct InstaError: Codable {

    var message: String
    var type: String
    var isTransient: Bool
    var code: Int
    var errorSubcode: Int
    var errorUserTitle: String
    var errorUserMsg: String
    var fbtraceId: String
    
    enum CodingKeys: String, CodingKey {
        case message
        case type
        case isTransient = "is_transient"
        case code
        case errorSubcode = "error_subcode"
        case errorUserTitle = "error_user_title"
        case errorUserMsg = "error_user_msg"
        case fbtraceId = "fbtrace_id"
    }
}

