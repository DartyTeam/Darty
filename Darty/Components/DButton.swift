//
//  DButton.swift
//  Darty
//
//  Created by Руслан Садыков on 17.04.2022.
//

import UIKit

enum DButtonType {
    case main
    case secondary

    var color: UIColor {
        switch self {
        case .main:
            return Colors.Elements.element
        case .secondary:
            return Colors.Elements.secondaryElement
        }
    }
}

class DButton: UIButton {

    private let type: DButtonType

    init(title: String? = "", type: DButtonType = .main) {
        self.type = type
        super.init(frame: .zero)
        self.backgroundColor = type.color
        self.setTitle(title, for: .normal)
        self.titleLabel?.numberOfLines = 0
        self.titleLabel?.textAlignment = .center
        self.titleEdgeInsets = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8)
        self.setTitleColor(.white, for: .normal)
        self.titleLabel?.font = .sfProRounded(ofSize: 17, weight: .semibold)
        setupCornerRadius()
        setupShadow()
    }

    private func setupCornerRadius() {
        self.layer.cornerRadius = 10
        self.layer.cornerCurve = .continuous
    }

    private func setupShadow() {
        self.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25).cgColor
        self.layer.shadowRadius = 4
        self.layer.shadowOpacity = 1
        self.layer.shadowOffset = CGSize(width: 0, height: 4)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var isEnabled: Bool {
        didSet {
            backgroundColor = isEnabled ? type.color : Colors.Elements.disabledElement
        }
    }
}
