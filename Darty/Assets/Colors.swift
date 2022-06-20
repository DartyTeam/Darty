//
//  Colors.swift
//  Darty
//
//  Created by Руслан Садыков on 26.03.2022.
//

import Foundation
import UIKit

enum Colors {
    enum Bubbles: CaseIterable {
        static let indigoBubble = UIColor(named: "IndigoBubble")!
        static let purplrBubble = UIColor(named: "PurpleBubble")!
        static let pinkBubble = UIColor(named: "PinkBubble")!
        static let orangeBubble = UIColor(named: "OrangeBubble")!
    }

    enum Backgorunds {
        static let plate = UIColor(named: "Plate")!
        static let screen = UIColor(named: "Screen")!
        static let inputView = UIColor(named: "InputView")!
        static let group = UIColor(named: "Group")!
    }

    enum Elements {
        static let element = UIColor(named: "Element")!
        static let secondaryElement = UIColor(named: "SecondaryElement")!
        static let disabledElement = UIColor(named: "DisabledElement")!
        static let line = UIColor(named: "Line")!
    }

    enum Statuses {
        static let error = UIColor(named: "Error")!
    }

    enum Text {
        static let main = UIColor(named: "Main")!
        static let secondary = UIColor(named: "Secondary")!
        static let onUnderlayers = UIColor(named: "OnUnderlayers")!
        static let placeholder = UIColor(named: "Placeholder")!
    }
}
