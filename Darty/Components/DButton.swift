//
//  DButton.swift
//  Darty
//
//  Created by Руслан Садыков on 17.04.2022.
//

import UIKit

class DButton: UIButton {

    private (set) var enabledBackground: UIColor?
    var disabledBackround: UIColor = .systemGray

    init(title: String? = "") {
        super.init(frame: .zero)
        self.setTitle(title, for: .normal)
        self.titleLabel?.numberOfLines = 0
        self.titleLabel?.textAlignment = .center
        self.titleEdgeInsets = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8)
        self.setTitleColor(.white, for: .normal)

        self.titleLabel?.font = .sfProRounded(ofSize: 17, weight: .semibold)

        self.layer.cornerRadius = 10
        self.layer.cornerCurve = .continuous

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
            backgroundColor = isEnabled ? (enabledBackground ?? .systemBlue) : disabledBackround
        }
    }

    override var backgroundColor: UIColor? {
        didSet {
            guard enabledBackground == nil, backgroundColor != disabledBackround else { return }
            enabledBackground = backgroundColor ?? .systemBlue
        }
    }
}