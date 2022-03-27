//
//  InterestNode.swift
//  Darty
//
//  Created by Руслан Садыков on 26.03.2022.
//

import Magnetic
import SpriteKit

final class InterestNode: Node {

    // MARK: - Properties
    var index: Int = 0

    // MARK: - Init
    override init(text: String? = nil, image: UIImage? = nil, color: UIColor, path: CGPath, marginScale: CGFloat = 1.01) {
        super.init(text: text, image: image, color: color, path: path, marginScale: marginScale)
        selectedColor = .white.withAlphaComponent(0.5)
        selectedFontColor = .black
        label.fontName = "SFProRounded-Bold"
        label.fontSize = 10
        scaleToFitContent = true
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func selectedAnimation() {
        super.selectedAnimation()
        label.run(.customAction(withDuration: animationDuration, actionBlock: { node, value in
            self.label.fontName = "SFProRounded-Semibold"
        }))
    }
}
