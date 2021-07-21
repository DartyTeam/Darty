//
//  SelfConfigutingCell.swift
//  Darty
//
//  Created by Руслан Садыков on 07.07.2021.
//

import Foundation

protocol SelfConfiguringCell {
    static var reuseId: String { get }
    func configure<P: Hashable>(with value: P)
}
