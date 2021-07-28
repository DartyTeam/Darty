//
//  DateFormatter + Extension.swift
//  Darty
//
//  Created by Руслан Садыков on 21.07.2021.
//

import Foundation

extension DateFormatter {
    static let ddMMyyyy: DateFormatter = {
        var dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy"
        dateFormatter.locale = .current
        return dateFormatter
    }()

    static let HHmm: DateFormatter = {
        var dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        dateFormatter.locale = .current
        return dateFormatter
    }()
    
    static let ddMMMM: DateFormatter = {
        var dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MMMM"
        dateFormatter.locale = .current
        return dateFormatter
    }()
}
