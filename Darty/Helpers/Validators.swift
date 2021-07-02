//
//  Validators.swift
//  Darty
//
//  Created by Руслан Садыков on 28.06.2021.
//

import Foundation

class Validators {
    
    static func isFilled(partyName: String?, aboutParty: String?) -> Bool {
        guard let partyName = partyName,
              let aboutParty = aboutParty,
              partyName != "",
              aboutParty != ""
        else { return false }
        
        return true
    }
    
    static func isFilled(email: String?, password: String?, confirmPassword: String?) -> Bool {
        guard let email = email,
              let password = password,
              let confirmPassword = confirmPassword,
              email != "",
              password != "",
              confirmPassword != ""
        else { return false }
        
        return true
    }
    
    static func isFilled(username: String?, description: String?, sex: Int?, birthday: Date?) -> Bool {
        guard let username = username,
              let description = description,
              let sex = sex,
              let birthday = birthday,
              username != "",
              description != ""
        else { return false }
        
        return true
    }
    
    static func isFilled(date: Date?, startTime: Date?, endTime: Date?) -> Bool {
        guard let date = date,
              let startTime = startTime,
              let endTime = endTime
        else { return false }
        
        return true
    }
    
    static func isFilled(date: Date?, startTime: Date?) -> Bool {
        guard let date = date,
              let startTime = startTime
        else { return false }
        
        return true
    }
    
    static func isSimpleEmail(_ email: String) -> Bool {
        let emailRegEx = "^.+@.+\\..{2,}$"
        return check(text: email, regEx: emailRegEx)
    }
    
    private static func check(text: String, regEx: String) -> Bool {
        let predicate = NSPredicate(format: "SELF MATCHES %@", regEx)
        return predicate.evaluate(with: text)
    }
}
