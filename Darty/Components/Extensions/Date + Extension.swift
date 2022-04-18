//
//  Date + Extension.swift
//  Darty
//
//  Created by Руслан Садыков on 24.08.2021.
//

import Foundation

extension Date {
    func interval(comp: Calendar.Component, fromDate: Date) -> Float {
        let currentCalendar = Calendar.current
        guard let start = currentCalendar.ordinality(of: comp, in: .era, for: fromDate) else { return .zero }
        guard let end = currentCalendar.ordinality(of: comp, in: .era, for: self) else { return .zero }
        
        return Float(start - end)
    }

    func age() -> Int {
        let calendar = Calendar.current
        return calendar.dateComponents([.year], from: self, to: Date()).year!
    }
}
