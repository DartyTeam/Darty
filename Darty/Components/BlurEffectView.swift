//
//  BlurEffectView.swift
//  Darty
//
//  Created by Руслан Садыков on 02.07.2021.
//

import UIKit

class BlurEffectView: UIVisualEffectView {
        
    // MARK: Private
    private var animator: UIViewPropertyAnimator!
    
    init(style: UIBlurEffect.Style = .systemUltraThinMaterial) {
        super.init(effect: nil)
        let effect = UIBlurEffect(style: style)
        animator = UIViewPropertyAnimator(duration: 1, curve: .linear) { [unowned self] in self.effect = effect}
        animator.fractionComplete = 0.27
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
