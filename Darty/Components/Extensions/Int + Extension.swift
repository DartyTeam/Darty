//
//  Int + Extension.swift
//  Darty
//
//  Created by Руслан Садыков on 18.07.2021.
//

import Foundation

extension Int {
     func parties() -> String {
         var partyString: String!
         if "1".contains("\(self % 10)")      {partyString = "вечеринка"}
         if "234".contains("\(self % 10)")    {partyString = "вечеринки" }
         if "567890".contains("\(self % 10)") {partyString = "вечеринок"}
         if 11...14 ~= self % 100                   {partyString = "вечеринок"}
    return "\(self) " + partyString
    }
    
    func requests() -> String {
        var requestString: String!
        if "1".contains("\(self % 10)")      {requestString = "заявка"}
        if "234".contains("\(self % 10)")    {requestString = "заявки" }
        if "567890".contains("\(self % 10)") {requestString = "заявок"}
        if 11...14 ~= self % 100                   {requestString = "заявок"}
   return "\(self) " + requestString
   }
}
