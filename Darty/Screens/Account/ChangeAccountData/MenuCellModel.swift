//
//  MenuCellModel.swift
//  Darty
//
//  Created by Руслан Садыков on 17.06.2022.
//

import UIKit

struct MenuCellModel {
    let title: String
    let icon: String
    let action: Selector
    var color: UIColor = Colors.Elements.element
}
